
const {setGlobalOptions} = require("firebase-functions");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");
const crypto = require("crypto");

admin.initializeApp();

setGlobalOptions({maxInstances: 5});

const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");

/**
 * Creates a Razorpay client using the configured secrets.
 * @return {Razorpay} The configured Razorpay client.
 */
function getRazorpay() {
  return new Razorpay({
    key_id: razorpayKeyId.value(),
    key_secret: razorpayKeySecret.value(),
  });
}

/**
 * Validates a value and returns it as a trimmed string.
 * @param {*} value The value to validate.
 * @param {string} field The field name for the error message.
 * @return {string} The validated string.
 * @throws {HttpsError} If the value is invalid.
 */
function requireText(value, field) {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError(
        "invalid-argument",
        `Invalid ${field}.`,
    );
  }
  return value.trim();
}

// STEP 1: Create an order using the actual Firestore slot prices.
exports.createRazorpayOrder = onCall(
    {secrets: [razorpayKeyId, razorpayKeySecret]},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Please log in first.");
      }

      const data = request.data || {};
      const turfId = requireText(data.turfId, "turf ID");
      const dateId = requireText(data.dateId, "date");
      const slotIds = data.slotIds;

      if (
        !/^\d{4}-\d{2}-\d{2}$/.test(dateId) ||
        !Array.isArray(slotIds) ||
        slotIds.length === 0 ||
        slotIds.length > 20 ||
        slotIds.some((id) =>
          typeof id !== "string" || !id.trim(),
        ) ||
        new Set(slotIds).size !== slotIds.length
      ) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid date or selected slots.",
        );
      }

      // These values are used as booking display details.
      // The server calculates the price from Firestore.
      const details = {
        turfName: requireText(data.turfName, "turf name"),
        turfOwnerId: requireText(data.turfOwnerId, "turf owner ID"),
        turfImage: typeof data.turfImage === "string" ?
          data.turfImage : "",
        turfLocation: typeof data.turfLocation === "string" ?
          data.turfLocation : "",
        customerName: requireText(data.customerName, "customer name"),
        sport: requireText(data.sport, "sport"),
      };

      const db = admin.firestore();
      const turfRef = db.collection("turfs").doc(turfId);
      const slotsRef = turfRef.collection("slots").doc(dateId)
          .collection("times");

      const turfSnapshot = await turfRef.get();

      if (!turfSnapshot.exists) {
        throw new HttpsError("not-found", "Turf not found.");
      }

      const slotSnapshots = await Promise.all(
          slotIds.map((id) => slotsRef.doc(id).get()),
      );

      let totalAmount = 0;

      for (const slot of slotSnapshots) {
        if (!slot.exists || slot.data().status !== "available") {
          throw new HttpsError(
              "failed-precondition",
              "One or more selected slots are no longer available.",
          );
        }

        const price = slot.data().price;

        if (
          typeof price !== "number" ||
          !Number.isFinite(price) ||
          price <= 0
        ) {
          throw new HttpsError(
              "failed-precondition",
              "Invalid slot price.",
          );
        }

        totalAmount += price;
      }

      const amount = Math.round(totalAmount * 100);

      if (!Number.isSafeInteger(amount) || amount <= 0) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid payment amount.",
        );
      }

      // Create a server-side record to bind this order to this user.
      const attemptRef = db.collection("paymentAttempts").doc();

      await attemptRef.set({
        userId: request.auth.uid,
        turfId,
        dateId,
        slotIds,
        amount,
        currency: "INR",
        details,
        status: "creating_order",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      try {
        const order = await getRazorpay().orders.create({
          amount,
          currency: "INR",
          receipt: attemptRef.id,
          notes: {
            attemptId: attemptRef.id,
            userId: request.auth.uid,
            turfId,
            dateId,
          },
        });

        await attemptRef.update({
          orderId: order.id,
          status: "pending",
        });

        return {
          attemptId: attemptRef.id,
          orderId: order.id,
          amount: order.amount,
          currency: order.currency,
          keyId: razorpayKeyId.value(),
        };
      } catch (error) {
        await attemptRef.update({status: "order_creation_failed"});
        console.error("Razorpay order creation failed:", error);
        throw new HttpsError(
            "internal",
            "Could not create the payment order.",
        );
      }
    },
);

// STEP 2: Verify payment and confirm the booking atomically.
exports.verifyRazorpayPayment = onCall(
    {secrets: [razorpayKeyId, razorpayKeySecret]},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Please log in first.");
      }

      const data = request.data || {};

      const orderId = requireText(data.orderId, "order ID");
      const paymentId = requireText(data.paymentId, "payment ID");
      const signature = requireText(data.signature, "signature");
      const attemptId = requireText(data.attemptId, "attempt ID");

      if (!/^[a-f0-9]{64}$/i.test(signature)) {
        throw new HttpsError(
            "invalid-argument",
            "Invalid payment signature format.",
        );
      }

      const db = admin.firestore();
      const attemptRef = db.collection("paymentAttempts").doc(attemptId);
      const attemptSnapshot = await attemptRef.get();

      if (!attemptSnapshot.exists) {
        throw new HttpsError("not-found", "Payment attempt not found.");
      }

      const attempt = attemptSnapshot.data();

      if (
        attempt.userId !== request.auth.uid ||
        attempt.orderId !== orderId
      ) {
        throw new HttpsError(
            "permission-denied",
            "This payment order does not belong to you.",
        );
      }

      // Idempotency: don't create a second booking on a repeated callback.
      if (attempt.status === "confirmed" && attempt.bookingId) {
        return {
          verified: true,
          bookingId: attempt.bookingId,
        };
      }

      if (attempt.status !== "pending") {
        throw new HttpsError(
            "failed-precondition",
            "This payment attempt cannot be processed.",
        );
      }

      const expectedSignature = crypto
          .createHmac("sha256", razorpayKeySecret.value())
          .update(`${orderId}|${paymentId}`)
          .digest();

      const receivedSignature = Buffer.from(signature, "hex");

      if (
        expectedSignature.length !== receivedSignature.length ||
        !crypto.timingSafeEqual(expectedSignature, receivedSignature)
      ) {
        throw new HttpsError(
            "permission-denied",
            "Payment signature verification failed.",
        );
      }

      // Confirm the payment and order status directly with Razorpay.
      let payment;
      let order;

      try {
        const razorpay = getRazorpay();
        [payment, order] = await Promise.all([
          razorpay.payments.fetch(paymentId),
          razorpay.orders.fetch(orderId),
        ]);
      } catch (error) {
        console.error("Razorpay status check failed:", error);
        throw new HttpsError(
            "unavailable",
            "Could not confirm payment status. Please try again.",
        );
      }

      if (
        payment.order_id !== orderId ||
        payment.status !== "captured" ||
        payment.amount !== attempt.amount ||
        payment.currency !== attempt.currency ||
        order.id !== orderId ||
        order.status !== "paid" ||
        order.amount !== attempt.amount ||
        order.currency !== attempt.currency
      ) {
        throw new HttpsError(
            "failed-precondition",
            "Payment is not confirmed as captured.",
        );
      }

      const turfRef = db.collection("turfs").doc(attempt.turfId);
      const slotsRef = turfRef.collection("slots").doc(attempt.dateId)
          .collection("times");
      const slotRefs = attempt.slotIds.map((id) => slotsRef.doc(id));
      const bookingRef = db.collection("bookings").doc();

      // All slot reads and writes happen in one transaction.
      const result = await db.runTransaction(async (tx) => {
        const latestAttempt = await tx.get(attemptRef);

        if (!latestAttempt.exists) {
          throw new Error("Payment attempt not found.");
        }

        const latest = latestAttempt.data();

        if (latest.status === "confirmed" && latest.bookingId) {
          return {bookingId: latest.bookingId};
        }

        if (
          latest.status !== "pending" ||
          latest.userId !== request.auth.uid ||
          latest.orderId !== orderId
        ) {
          throw new Error("Payment attempt is no longer pending.");
        }

        const turfSnapshot = await tx.get(turfRef);
        const slotSnapshots = [];

        for (const slotRef of slotRefs) {
          slotSnapshots.push(await tx.get(slotRef));
        }

        if (!turfSnapshot.exists) {
          return {conflict: "Turf no longer exists."};
        }

        for (const slot of slotSnapshots) {
          if (!slot.exists || slot.data().status !== "available") {
            return {
              conflict: "A selected slot has already been booked.",
            };
          }
        }

        const slots = slotSnapshots.map((snapshot) => snapshot.data());
        const currentAmount = slots.reduce((sum, slot) => {
          const price = slot.price;
          if (
            typeof price !== "number" ||
            !Number.isFinite(price) ||
            price <= 0
          ) {
            throw new Error("Invalid slot price.");
          }
          return sum + Math.round(price * 100);
        }, 0);

        if (currentAmount !== latest.amount) {
          return {conflict: "The slot price has changed."};
        }

        slots.sort((a, b) =>
          a.startAt.toMillis() - b.startAt.toMillis(),
        );

        const startAt = slots[0].startAt;
        const endAt = slots[slots.length - 1].endAt;
        const details = latest.details;

        tx.set(bookingRef, {
          bookingId: bookingRef.id,
          turfId: latest.turfId,
          turfName: details.turfName,
          turfOwnerId: details.turfOwnerId,
          customerName: details.customerName,
          turfImage: details.turfImage,
          turfLocation: details.turfLocation,
          userId: latest.userId,
          date: latest.dateId,
          slotIds: latest.slotIds,
          startAt,
          endAt,
          duration: latest.slotIds.length,
          totalAmount: latest.amount / 100,
          sport: details.sport,
          paymentMethod: "razorpay",
          paymentStatus: "paid",
          razorpayOrderId: orderId,
          razorpayPaymentId: paymentId,
          isDemo: false,
          status: "confirmed",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        tx.update(turfRef, {
          bookingCount: admin.firestore.FieldValue.increment(1),
        });

        for (const slotRef of slotRefs) {
          tx.update(slotRef, {
            status: "booked",
            bookingId: bookingRef.id,
          });
        }

        tx.update(attemptRef, {
          status: "confirmed",
          bookingId: bookingRef.id,
          paymentId,
          confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {bookingId: bookingRef.id};
      });

      if (result.conflict) {
        // Payment succeeded, but booking could not be secured.
        // Do not silently treat this as a successful booking.
        await attemptRef.update({
          status: "paid_booking_conflict",
          paymentId,
          conflictReason: result.conflict,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        throw new HttpsError(
            "failed-precondition",
            "Payment succeeded, but the slot is no longer available. " +
            "Contact support to arrange a refund.",
        );
      }

      return {
        verified: true,
        bookingId: result.bookingId,
      };
    },
);
