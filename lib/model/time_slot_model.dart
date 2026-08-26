import 'package:cloud_firestore/cloud_firestore.dart';

class SlotModel {
  final String? id;
  final DateTime startAt;
  final DateTime endAt;
  final double price;
  final String status;
  final String? bookingId;

  SlotModel({
    this.id,
    required this.startAt,
    required this.endAt,
    required this.price,
    this.status = 'available',
    this.bookingId,
  });

  Map<String, dynamic> toMap() {
    return {
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'price': price,
      'status': status,
      'bookingId': bookingId,
    };
  }
}