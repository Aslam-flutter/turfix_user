import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfix/model/date_booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final List<BookingDateModel> dates = [];

  // --------------------------------------------------
  // DATE
  // --------------------------------------------------

  DateTime? selectedDate;

  int selectedDateIndex = 0;

  // --------------------------------------------------
  // SELECTED SLOTS
  // --------------------------------------------------

  final List<String> selectedSlotIds = [];

  // Store selected slot data
  final List<Map<String, dynamic>> selectedSlots = [];

  BookingProvider() {
    generateDates();
  }

  // --------------------------------------------------
  // GENERATE 7 DAYS
  // --------------------------------------------------

  void generateDates() {
    dates.clear();

    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: i));

      dates.add(BookingDateModel(date: date, selected: i == 0));
    }

    selectedDate = dates.first.date;
    selectedDateIndex = 0;
  }

  // --------------------------------------------------
  // DATE ID
  // Example: 2026-08-20
  // --------------------------------------------------

  String get dateFormat {
    if (selectedDate == null) {
      return '';
    }

    return selectedDate!.toIso8601String().split('T').first;
  }

  // --------------------------------------------------
  // SELECT DATE
  // --------------------------------------------------

  void selectDate(int index) {
    for (int i = 0; i < dates.length; i++) {
      dates[i].selected = i == index;
    }

    selectedDateIndex = index;

    selectedDate = dates[index].date;

    // Clear previously selected slots
    selectedSlotIds.clear();
    selectedSlots.clear();

    notifyListeners();
  }

  // --------------------------------------------------
  // CHECK WHETHER SLOT IS SELECTED
  // --------------------------------------------------

  bool isSlotSelected(String slotId) {
    return selectedSlotIds.contains(slotId);
  }

  // --------------------------------------------------
  // CHECK WHETHER SLOT CAN BE SELECTED
  //
  // Only consecutive slots are allowed.
  // --------------------------------------------------

  bool canSelectSlot({
    required int index,
    required List<String> slotIds,
    required List<String> availableSlotIds,
  }) {
    // First slot can always be selected
    if (selectedSlotIds.isEmpty) {
      return true;
    }

    final currentSlotId = slotIds[index];

    // Already selected
    if (selectedSlotIds.contains(currentSlotId)) {
      return true;
    }

    // Find currently selected indexes
    final selectedIndexes = selectedSlotIds
        .map((id) => slotIds.indexOf(id))
        .where((index) => index != -1)
        .toList();

    if (selectedIndexes.isEmpty) {
      return true;
    }

    selectedIndexes.sort();

    final firstIndex = selectedIndexes.first;
    final lastIndex = selectedIndexes.last;

    // Only allow next or previous slot
    final isNext = index == lastIndex + 1;
    final isPrevious = index == firstIndex - 1;

    if (!isNext && !isPrevious) {
      return false;
    }

    // Make sure the slot is actually available
    if (!availableSlotIds.contains(currentSlotId)) {
      return false;
    }

    return true;
  }

  // --------------------------------------------------
  // SELECT / UNSELECT SLOT
  // --------------------------------------------------

  void toggleSlot({
    required String slotId,
    required Map<String, dynamic> slotData,
  }) {
    if (selectedSlotIds.contains(slotId)) {
      selectedSlotIds.remove(slotId);

      selectedSlots.removeWhere((slot) => slot['slotId'] == slotId);
    } else {
      selectedSlotIds.add(slotId);

      selectedSlots.add({'slotId': slotId, ...slotData});
    }

    notifyListeners();
  }

  // --------------------------------------------------
  // SORT SELECTED SLOTS
  // --------------------------------------------------

  void sortSelectedSlots() {
    selectedSlots.sort((a, b) {
      final aTime = (a['startAt'] as Timestamp).toDate();

      final bTime = (b['startAt'] as Timestamp).toDate();

      return aTime.compareTo(bTime);
    });

    selectedSlotIds
      ..clear()
      ..addAll(selectedSlots.map((slot) => slot['slotId'] as String));
  }

  // --------------------------------------------------
  // TOTAL PRICE
  // --------------------------------------------------

  double get totalPrice {
    double total = 0;

    for (final slot in selectedSlots) {
      final price = slot['price'];

      if (price is int) {
        total += price.toDouble();
      } else if (price is double) {
        total += price;
      } else {
        total += double.tryParse(price.toString()) ?? 0;
      }
    }

    return total;
  }

  // --------------------------------------------------
  // TOTAL HOURS
  // --------------------------------------------------

  int get totalHours {
    return selectedSlotIds.length;
  }

  // --------------------------------------------------
  // FIRST START TIME
  // --------------------------------------------------

  DateTime? get bookingStartTime {
    if (selectedSlots.isEmpty) {
      return null;
    }

    sortSelectedSlots();

    return (selectedSlots.first['startAt'] as Timestamp).toDate();
  }

  // --------------------------------------------------
  // LAST END TIME
  // --------------------------------------------------

  DateTime? get bookingEndTime {
    if (selectedSlots.isEmpty) {
      return null;
    }

    sortSelectedSlots();

    return (selectedSlots.last['endAt'] as Timestamp).toDate();
  }

  // --------------------------------------------------
  // CLEAR SELECTION
  // --------------------------------------------------

  void clearSelection() {
    selectedSlotIds.clear();
    selectedSlots.clear();

    notifyListeners();
  }

  //--------------------------------------------------
  String formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  // --------------------------------------------------
  // BOOK MULTIPLE SLOTS
  // --------------------------------------------------

  Future<String> bookSlots({
    required String turfId,
    required String turfName,
    required String customerName,
    required String turfOwnerId,
    required String turfImage,
    required String turfLocation,
    required String userId,
    required String sport,
    required String paymentMethod,
  }) async {
    final firestore = FirebaseFirestore.instance;

    if (selectedDate == null || selectedSlotIds.isEmpty) {
      throw Exception('Date or slot not selected');
    }

    // Make sure selectedSlots are in time order
    sortSelectedSlots();

    final dateId = formatDate(selectedDate!);

    // Create booking document reference
    final bookingRef = firestore.collection('bookings').doc();

    // Create references to selected slots
    final slotRefs = selectedSlotIds.map((slotId) {
      return firestore
          .collection('turfs')
          .doc(turfId)
          .collection('slots')
          .doc(dateId)
          .collection('times')
          .doc(slotId);
    }).toList();

    await firestore.runTransaction((transaction) async {
      // -----------------------------------------
      // 1. READ ALL SELECTED SLOTS
      // -----------------------------------------

      final slotSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];

      for (final slotRef in slotRefs) {
        final snapshot = await transaction.get(slotRef);

        if (!snapshot.exists) {
          throw Exception('One of the selected slots does not exist.');
        }

        slotSnapshots.add(snapshot);
      }

      // -----------------------------------------
      // 2. CHECK AVAILABILITY
      // -----------------------------------------

      for (final snapshot in slotSnapshots) {
        final data = snapshot.data()!;

        if (data['status'] != 'available') {
          throw Exception('One of the selected slots is already booked.');
        }
      }

      // -----------------------------------------
      // 3. CREATE BOOKING
      // -----------------------------------------

      transaction.set(bookingRef, {
        'bookingId': bookingRef.id,
        'turfId': turfId,
        'turfName': turfName,
        'turfOwnerId': turfOwnerId,
        'customerName': customerName,
        'turfImage': turfImage,
        'turfLocation': turfLocation,
        'userId': userId,
        'date': dateId,
        'slotIds': selectedSlotIds,
        'startAt': Timestamp.fromDate(bookingStartTime!),
        'endAt': Timestamp.fromDate(bookingEndTime!),
        'duration': totalHours,
        'totalAmount': totalPrice,
        'sport': sport,
        'paymentMethod': paymentMethod,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // -----------------------------------------
      // 4. CHANGE SLOTS TO BOOKED
      // -----------------------------------------

      for (final slotRef in slotRefs) {
        transaction.update(slotRef, {
          'status': 'booked',
          'bookingId': bookingRef.id,
        });
      }
    });

    debugPrint('Booking successful: ${bookingRef.id}');

    return bookingRef.id;
  }

  Future<String?> getCustomerName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return 'no user';

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return 'no user';

    return doc.data()?['name']?.toString();
  }
}
