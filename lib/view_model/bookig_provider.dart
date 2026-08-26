import 'package:cloud_firestore/cloud_firestore.dart';
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

  // --------------------------------------------------
  // BOOK MULTIPLE SLOTS
  // --------------------------------------------------

  Future<String> bookSlots({
    required String turfId,
    required String userId,
    required String sport,
    required String paymentMethod,
  }) async {
    if (selectedSlotIds.isEmpty) {
      throw Exception('Please select at least one slot.');
    }

    if (selectedDate == null) {
      throw Exception('Please select a date.');
    }

    sortSelectedSlots();

    final firestore = FirebaseFirestore.instance;

    final dateId = dateFormat;

    final bookingRef = firestore.collection('bookings').doc();

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
      // ------------------------------------------
      // 1. READ ALL SLOTS FIRST
      // ------------------------------------------

      final slotSnapshots = <DocumentSnapshot>[];

      for (final slotRef in slotRefs) {
        final snapshot = await transaction.get(slotRef);

        if (!snapshot.exists) {
          throw Exception('One of the selected slots does not exist.');
        }

        slotSnapshots.add(snapshot);
      }

      // ------------------------------------------
      // 2. CHECK ALL SLOTS
      // ------------------------------------------

      for (final snapshot in slotSnapshots) {
        final data = snapshot.data() as Map<String, dynamic>;

        if (data['status'] != 'available') {
          throw Exception(
            'One of your selected slots has already been booked.',
          );
        }
      }

      // ------------------------------------------
      // 3. CREATE BOOKING
      // ------------------------------------------

      transaction.set(bookingRef, {
        'turfId': turfId,
        'userId': userId,

        'dateId': dateId,

        'slotIds': selectedSlotIds,

        'startAt': Timestamp.fromDate(bookingStartTime!),

        'endAt': Timestamp.fromDate(bookingEndTime!),

        'duration': totalHours,

        'price': totalPrice,

        'sport': sport,

        'paymentMethod': paymentMethod,

        'status': 'confirmed',

        'createdAt': FieldValue.serverTimestamp(),
      });

      // ------------------------------------------
      // 4. MARK ALL SLOTS AS BOOKED
      // ------------------------------------------

      for (final slotRef in slotRefs) {
        transaction.update(slotRef, {
          'status': 'booked',
          'bookingId': bookingRef.id,
        });
      }
    });

    return bookingRef.id;
  }
}
