import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turfix/view/screens/user_screens/booking_screen.dart';

class CommonProvider extends ChangeNotifier {
  bool isLoading = false;
  String bookDate = DateFormat('d MMMM yyyy').format(DateTime.now());
  bool imageErrored = false;
  bool isObscure = true;
  String selectedPaymentMethod = PaymentMethod.upi.name;

  void selectPaymentMethod(String value) {
    selectedPaymentMethod = value;
    notifyListeners();
  }

  void pickBookDate(BuildContext context) async {
    final picker = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picker != null) {
      bookDate = DateFormat('d MMMM yyyy').format(picker);
      notifyListeners();
    }
  }

  void load(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void imageError(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void obscurePassword() {
    isObscure = !isObscure;
    notifyListeners();
  }

  String getDisplayStatus(Map<String, dynamic> booking) {
    // Cancellation is stored permanently in Firebase
    if (booking['status']?.toString().toLowerCase() == 'cancelled') {
      return 'Cancelled';
    }

    final startAt = booking['startAt'];

    final endAt = booking['endAt'];

    if (startAt is! Timestamp || endAt is! Timestamp) {
      return 'Confirmed';
    }

    final now = DateTime.now();

    final startTime = startAt.toDate();
    final endTime = endAt.toDate();

    if (now.isBefore(startTime)) {
      return 'Confirmed';
    }

    if (now.isBefore(endTime)) {
      return 'Playing';
    }

    return 'Completed';
  }



  
}


