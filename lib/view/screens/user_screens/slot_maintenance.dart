import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix/view_model/slot_provider.dart';

class SlotMaintenance extends StatelessWidget {
  final Widget child;

  const SlotMaintenance({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SlotProvider>().maintainSlotsForAllTurfs();
    });

    return child;
  }
}
