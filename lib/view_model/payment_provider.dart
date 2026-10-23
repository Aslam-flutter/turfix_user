import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:turfix/widgets/scaffold_messaneger.dart';

class PaymentProvider extends ChangeNotifier {
  Razorpay? _razorpay;

  Completer<Map<String, dynamic>?>? _paymentCompleter;

  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  void _setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> handleOnlinePayment({
    required BuildContext context,
    required String method,
    required String turfId,
    required String dateId,
    required List<String> slotIds,
    required String turfName,
    required String turfOwnerId,
    required String turfImage,
    required String turfLocation,
    required String customerName,
    required String sport,
  }) async {
    if (_isProcessing) return null;

    _paymentCompleter = Completer<Map<String, dynamic>?>();
    _setProcessing(true);

    try {
      final createOrder = FirebaseFunctions.instance.httpsCallable(
        'createRazorpayOrder',
      );

      final response = await createOrder.call({
        'turfId': turfId,
        'dateId': dateId,
        'slotIds': slotIds,
        'turfName': turfName,
        'turfOwnerId': turfOwnerId,
        'turfImage': turfImage,
        'turfLocation': turfLocation,
        'customerName': customerName,
        'sport': sport,
      });

      final order = Map<String, dynamic>.from(response.data as Map);

      final keyId = order['keyId'] as String;
      final orderId = order['orderId'] as String;
      final attemptId = order['attemptId'] as String;
      _currentAttemptId = attemptId;
      final amount = (order['amount'] as num).toInt();

      _razorpay ??= Razorpay();
      _razorpay!
        ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess)
        ..on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError)
        ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

      _razorpay!.open({
        'key': keyId,
        'order_id': orderId,
        'amount': amount,
        'currency': 'INR',
        'name': 'Turfix',
        'description': '$turfName booking',
        'prefill': {'name': customerName},
        'notes': {'attemptId': attemptId, 'paymentMethod': method},
        'theme': {'color': '#16A34A'},
      });

      final result = await _paymentCompleter!.future;

      if (result == null && context.mounted) {
        AppMessenger.customScaffoldMessenger(
          context,
          message: 'Payment was cancelled or could not be completed.',
        );
      }

      return result;
    } catch (e) {
      if (context.mounted) {
        AppMessenger.customScaffoldMessenger(
          context,
          message: 'Payment error: $e',
        );
      }
      return null;
    } finally {
      _paymentCompleter = null;
      _setProcessing(false);
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final orderId = response.orderId;
      final paymentId = response.paymentId;
      final signature = response.signature;

      if (orderId == null || paymentId == null || signature == null) {
        throw Exception('Incomplete payment response.');
      }

      // This value is stored in checkout notes, but callback notes are
      // not returned by Razorpay. Keep the attempt ID from order creation.
      final attemptId = _currentAttemptId;

      if (attemptId == null) {
        throw Exception('Payment attempt is missing.');
      }

      final verifyPayment = FirebaseFunctions.instance.httpsCallable(
        'verifyRazorpayPayment',
      );

      final result = await verifyPayment.call({
        'attemptId': attemptId,
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
      });

      final data = Map<String, dynamic>.from(result.data as Map);

      if (data['verified'] == true && data['bookingId'] != null) {
        _completePayment({
          'bookingId': data['bookingId'],
          'paymentId': paymentId,
        });
      } else {
        _completePayment(null);
      }
    } catch (_) {
      _completePayment(null);
    }
  }

  String? _currentAttemptId;

  void _completePayment(Map<String, dynamic>? result) {
    final completer = _paymentCompleter;

    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _completePayment(null);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // Wallet selection does not mean payment has succeeded.
  }

  void disposePayment() {
    _razorpay?.clear();
    _razorpay = null;
  }

  @override
  void dispose() {
    disposePayment();
    super.dispose();
  }
}
