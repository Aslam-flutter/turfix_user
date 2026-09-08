import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SlotProvider extends ChangeNotifier {
  TimeOfDay parseTime(String time) {
    final parts = time.trim().split(' ');
    final timePart = parts[0];
    final period = parts[1].toUpperCase();

    final timeParts = timePart.split(':');

    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> maintainRollingSlots({
    required String turfId,
    required String openingTime,
    required String closingTime,
    required double pricePerHour,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final opening = parseTime(openingTime);
    final closing = parseTime(closingTime);

    final slotsRef = firestore
        .collection('turfs')
        .doc(turfId)
        .collection('slots');

    final today = DateTime.now();

    final todayDate = DateTime(today.year, today.month, today.day);

    // ==================================================
    // 1. DELETE OLD DATES
    // ==================================================

    final allDateDocs = await slotsRef.get();

    for (final dateDoc in allDateDocs.docs) {
      final date = DateTime.tryParse(dateDoc.id);

      if (date == null) {
        continue;
      }

      // Delete dates before today
      if (date.isBefore(todayDate)) {
        final timesSnapshot = await dateDoc.reference.collection('times').get();

        WriteBatch deleteBatch = firestore.batch();

        int deleteCount = 0;

        for (final timeDoc in timesSnapshot.docs) {
          final data = timeDoc.data();

          // Don't delete booked slots
          if (data['status'] == 'booked') {
            continue;
          }

          deleteBatch.delete(timeDoc.reference);

          deleteCount++;

          if (deleteCount == 500) {
            await deleteBatch.commit();

            deleteBatch = firestore.batch();
            deleteCount = 0;
          }
        }

        if (deleteCount > 0) {
          await deleteBatch.commit();
        }

        // If there are no remaining slots,
        // delete the date document.
        final remainingSlots = await dateDoc.reference
            .collection('times')
            .limit(1)
            .get();

        if (remainingSlots.docs.isEmpty) {
          await dateDoc.reference.delete();
        }
      }
    }

    // ==================================================
    // 2. CREATE / MAINTAIN NEXT 7 DAYS
    // ==================================================

    for (int day = 0; day < 7; day++) {
      final currentDate = todayDate.add(Duration(days: day));

      // Example:
      // 2026-08-26

      final dateId =
          '${currentDate.year}-'
          '${currentDate.month.toString().padLeft(2, '0')}-'
          '${currentDate.day.toString().padLeft(2, '0')}';

      // ------------------------------------------------
      // DATE DOCUMENT
      // ------------------------------------------------

      final dateRef = slotsRef.doc(dateId);

      await dateRef.set({
        'date': Timestamp.fromDate(currentDate),
      }, SetOptions(merge: true));

      // ------------------------------------------------
      // TIME SLOTS
      // ------------------------------------------------

      final timesRef = dateRef.collection('times');

      DateTime start = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        opening.hour,
        opening.minute,
      );

      final closingDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        closing.hour,
        closing.minute,
      );

      WriteBatch batch = firestore.batch();

      int batchCount = 0;

      while (start.isBefore(closingDateTime)) {
        final end = start.add(const Duration(hours: 1));

        // Don't create a slot beyond closing time
        if (end.isAfter(closingDateTime)) {
          break;
        }

        // Example:
        // 05-00
        // 06-00
        // 07-00

        final slotId =
            '${start.hour.toString().padLeft(2, '0')}-'
            '${start.minute.toString().padLeft(2, '0')}';

        final slotRef = timesRef.doc(slotId);

        final slotSnapshot = await slotRef.get();

        // IMPORTANT:
        // merge:true means existing booked slots
        // won't be overwritten.
        if (!slotSnapshot.exists) {
          batch.set(slotRef, {
            'startAt': Timestamp.fromDate(start),
            'endAt': Timestamp.fromDate(end),
            'price': pricePerHour,
            'status': 'available',
            'bookingId': null,
            'createdAt': FieldValue.serverTimestamp(),
          });

          batchCount++;
        }

        if (batchCount == 500) {
          await batch.commit();

          batch = firestore.batch();
          batchCount = 0;
        }

        start = end;
      }

      if (batchCount > 0) {
        await batch.commit();
      }
    }

    debugPrint('Rolling slots updated for turf: $turfId');
  }

  bool _slotsMaintained = false;

  Future<void> maintainSlotsForAllTurfs() async {
    if (_slotsMaintained) return;

    _slotsMaintained = true;

    try {
      final firestore = FirebaseFirestore.instance;

      final snapshot = await firestore.collection('turfs').get();

      for (final turfDoc in snapshot.docs) {
        final data = turfDoc.data();

        await maintainRollingSlots(
          turfId: turfDoc.id,
          openingTime: data['openingTime'],
          closingTime: data['closingTime'],
          pricePerHour: (data['pricePerHour'] as num).toDouble(),
        );
      }
    } catch (e) {
      debugPrint('Slot maintenance error: $e');

      // Allow retry if it failed
      _slotsMaintained = false;
    }
  }
}
