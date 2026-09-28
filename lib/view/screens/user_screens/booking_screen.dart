import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turfix/view/screens/user_screens/booking_confirmed_screen.dart';
import 'package:turfix/view_model/bookig_provider.dart';
import 'package:turfix/view_model/common_provider.dart';
import 'package:turfix/view_model/payment_provider.dart';

enum PaymentMethod { upi, card, wallet, netBanking, payAtVenue }

class BookingScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> turf;
  final DateTime date;
  final List<Map<String, dynamic>> selectedSlots;
  final String customerName;
  const BookingScreen({
    super.key,
    required this.turf,
    required this.date,
    required this.selectedSlots,
    required this.customerName,
  });

  DateTime get startTime {
    return (selectedSlots.first['startAt'] as Timestamp).toDate();
  }

  DateTime get endTime {
    return (selectedSlots.last['endAt'] as Timestamp).toDate();
  }

  int get duration {
    return selectedSlots.length;
  }

  double get totalAmount {
    return selectedSlots.fold(0, (total, slot) {
      return total + (slot['price'] as num).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xff16A34A);
    final provider = Provider.of<CommonProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final selectedDate = DateFormat('d MMMM yyyy').format(date);
    final time =
        '${DateFormat('h:mm a').format(startTime)}'
        ' - '
        '${DateFormat('h:mm a').format(endTime)}';
    final timeDuration = '$duration Hour${duration > 1 ? 's' : ''}';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Booking",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  provider.load(true);
                  try {
                    final providerr = context.read<BookingProvider>();

                    final bookingId = await providerr.bookSlots(
                      turfId: turf.id,
                      turfName: turf['turfName'],
                      customerName: customerName,
                      turfOwnerId: turf['ownerId'],
                      turfImage: turf['turfImages'][0],
                      turfLocation: turf['location'],
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      sport: 'football',
                      paymentMethod: provider.selectedPaymentMethod,
                    );

                    if (!context.mounted) return;

                    provider.selectedPaymentMethod !=
                            PaymentMethod.payAtVenue.name
                        ? paymentProvider.handleOnlinePayment(
                            context,
                            provider.selectedPaymentMethod,
                          )
                        : null;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingConfirmedScreen(
                          turfName: turf['turfName'],
                          turfLocation: turf['location'],
                          bookingId: bookingId,
                          paymentMethod: provider.selectedPaymentMethod,
                          date: selectedDate,
                          amount: totalAmount.toStringAsFixed(0),
                          sport: 'Football',
                          time: time,
                          timeDuration: timeDuration,
                          imageUrl: turf['turfImages'][0],
                        ),
                      ),
                      (route) => false,
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceFirst('Exception: ', ''),
                        ),
                      ),
                    );
                  }

                  provider.load(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        "Book Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "You can cancel up to 2 hours before\nyour booking time.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      turf['turfImages'][0],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turf['turfName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        turf['location'],
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 35),

              BookingInfo(title: "Date", value: selectedDate),

              const SizedBox(height: 25),

              BookingInfo(
                title: "Time",
                value:
                    '${DateFormat('h:mm a').format(startTime)}'
                    ' - '
                    '${DateFormat('h:mm a').format(endTime)}',
              ),
              const SizedBox(height: 25),

              const BookingInfo(title: "Sport", value: "Football"),

              const SizedBox(height: 25),

              BookingInfo(
                title: "Total Duration",
                value: '$duration Hour${duration > 1 ? 's' : ''}',
              ),

              const SizedBox(height: 25),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '₹${totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 26,
                      color: green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Divider(endIndent: 8, indent: 8),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Method",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Choose your preferred payment option",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: () {
                      provider.selectPaymentMethod(PaymentMethod.upi.name);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            provider.selectedPaymentMethod ==
                                PaymentMethod.upi.name
                            ? const Color(0xffF2FCF5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              provider.selectedPaymentMethod ==
                                  PaymentMethod.upi.name
                              ? const Color(0xff16A34A)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(width: 16),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UPI',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Pay using any UPI app",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            provider.selectedPaymentMethod ==
                                    PaymentMethod.upi.name
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                provider.selectedPaymentMethod ==
                                    PaymentMethod.upi.name
                                ? const Color(0xff16A34A)
                                : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      provider.selectPaymentMethod(
                        PaymentMethod.payAtVenue.name,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            provider.selectedPaymentMethod ==
                                PaymentMethod.payAtVenue.name
                            ? const Color(0xffF2FCF5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              provider.selectedPaymentMethod ==
                                  PaymentMethod.payAtVenue.name
                              ? const Color(0xff16A34A)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.payments_outlined,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(width: 16),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pay at Venue',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Pay at the time of visit',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            provider.selectedPaymentMethod ==
                                    PaymentMethod.payAtVenue.name
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                provider.selectedPaymentMethod ==
                                    PaymentMethod.payAtVenue.name
                                ? const Color(0xff16A34A)
                                : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // paymentTile(
                  //   icon: Icons.account_balance_wallet_outlined,
                  //   title: "UPI",
                  //   subtitle: "Pay using any UPI app",
                  //   selected:
                  //       provider.selectedPaymentMethod ==
                  //       PaymentMethod.upi.name,
                  //   onTap: () {
                  //     provider.selectPaymentMethod(PaymentMethod.upi.name);
                  //   },
                  // ),

                  // paymentTile(
                  //   icon: Icons.credit_card_outlined,
                  //   title: "Credit / Debit Card",
                  //   subtitle: "Visa, MasterCard, Rupay",
                  //   selected:
                  //       provider.selectedPaymentMethod ==
                  //       PaymentMethod.card.name,
                  //   onTap: () {
                  //     provider.selectPaymentMethod(PaymentMethod.card.name);
                  //   },
                  // ),

                  // paymentTile(
                  //   icon: Icons.account_balance_wallet,
                  //   title: "Wallets",
                  //   subtitle: "Pay using wallet balance",
                  //   selected:
                  //       provider.selectedPaymentMethod ==
                  //       PaymentMethod.wallet.name,
                  //   onTap: () {
                  //     provider.selectPaymentMethod(PaymentMethod.wallet.name);
                  //   },
                  // ),

                  // paymentTile(
                  //   icon: Icons.account_balance_outlined,
                  //   title: "Net Banking",
                  //   subtitle: "All major banks supported",
                  //   selected:
                  //       provider.selectedPaymentMethod ==
                  //       PaymentMethod.netBanking.name,
                  //   onTap: () {
                  //     provider.selectPaymentMethod(
                  //       PaymentMethod.netBanking.name,
                  //     );
                  //   },
                  // ),

                  // paymentTile(
                  //   icon: Icons.payments_outlined,
                  //   title: "Pay at Venue",
                  //   subtitle: "Pay at the time of visit",
                  //   selected:
                  //       provider.selectedPaymentMethod ==
                  //       PaymentMethod.payAtVenue.name,
                  //   onTap: () {
                  //     provider.selectPaymentMethod(
                  //       PaymentMethod.payAtVenue.name,
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const BookingInfo({
    super.key,
    required this.title,
    required this.value,
    this.valueColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 15)),

        const SizedBox(height: 6),

        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Widget paymentTile({
//   required IconData icon,
//   required String title,
//   required String subtitle,
//   required bool selected,
//   required VoidCallback onTap,
// }) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 14),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: selected ? const Color(0xffF2FCF5) : Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(
//         color: selected ? const Color(0xff16A34A) : Colors.grey.shade300,
//       ),
//     ),
//     child: Row(
//       children: [
//         Container(
//           height: 48,
//           width: 48,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: Colors.black87),
//         ),

//         const SizedBox(width: 16),

//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 4),

//               Text(
//                 subtitle,
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//               ),
//             ],
//           ),
//         ),

//         Radio<bool>(
//           value: true,
//           groupValue: selected,
//           activeColor: const Color(0xff16A34A),
//           onChanged: (_) {
//             onTap();
//           },
//         ),
//       ],
//     ),
//   );
// }
