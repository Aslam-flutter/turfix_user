import 'package:flutter/material.dart';
import 'package:turfix/widgets/scaffold_messaneger.dart';

class PaymentProvider extends ChangeNotifier {
  Future<void> handleOnlinePayment(BuildContext context, String method) async {
    AppMessenger.customScaffoldMessenger(
      context,
      message: '$method payment will be integrated soon.',
    );
  }
}
