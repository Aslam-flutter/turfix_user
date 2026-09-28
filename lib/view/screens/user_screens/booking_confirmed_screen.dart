import 'package:flutter/material.dart';
import 'package:turfix/view/screens/user_screens/booking_screen.dart';
import 'package:turfix/view/screens/user_screens/my_booking_screen.dart';
import 'package:turfix/view/screens/user_screens/user_main_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final String turfName;
  final String turfLocation;
  final String bookingId;
  final String paymentMethod;
  final String date;
  final String time;
  final String timeDuration;
  final String sport;
  final String amount;
  final String imageUrl;
  const BookingConfirmedScreen({
    super.key,
    required this.turfName,
    required this.turfLocation,
    required this.time,
    required this.amount,
    required this.bookingId,
    required this.date,
    required this.paymentMethod,
    required this.sport,
    required this.timeDuration,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

    return Scaffold(
      backgroundColor: Colors.white10,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 90,
                  width: 90,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Booking Confirmed!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Your booking is confirmed\nand we're ready for your game!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 35),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  turfName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  turfLocation,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(endIndent: 14, indent: 14),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          const Text(
                            "Booking ID",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),

                          SizedBox(height: 8),

                          Text(
                            "#$bookingId",
                            style: const TextStyle(
                              color: Color(0xff16A34A),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      const Divider(endIndent: 14, indent: 14),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          /// Booking ID
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "Payment Method",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  paymentMethod == PaymentMethod.upi.name
                                      ? 'UPI'
                                      : 'Pay at Venue',
                                  style: const TextStyle(
                                    color: Color(0xff16A34A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 55,
                            color: Colors.grey.shade300,
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "Payment Status",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffEAF8EE),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color:
                                          paymentMethod ==
                                              PaymentMethod.upi.name
                                          ? const Color(0xff16A34A)
                                          : Colors.red,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 9,
                                        backgroundColor:
                                            paymentMethod ==
                                                PaymentMethod.upi.name
                                            ? const Color(0xff16A34A)
                                            : Colors.red,
                                        child:
                                            paymentMethod ==
                                                PaymentMethod.upi.name
                                            ? const Icon(
                                                Icons.check,
                                                size: 13,
                                                color: Colors.white,
                                              )
                                            : const Icon(
                                                Icons.close,
                                                size: 13,
                                                color: Colors.white,
                                              ),
                                      ),

                                      const SizedBox(width: 8),

                                      Text(
                                        paymentMethod == PaymentMethod.upi.name
                                            ? "Paid"
                                            : "Unpaid",
                                        style: TextStyle(
                                          color:
                                              paymentMethod ==
                                                  PaymentMethod.upi.name
                                              ? const Color(0xff16A34A)
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Divider(endIndent: 14, indent: 14),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            bookingDetail(
                              icon: Icons.calendar_today_outlined,
                              title: "Date",
                              value: date,
                            ),

                            const SizedBox(height: 16),

                            bookingDetail(
                              icon: Icons.access_time,
                              title: "Time",
                              value: time,
                            ),

                            const SizedBox(height: 16),

                            bookingDetail(
                              icon: Icons.sports_soccer,
                              title: "Sport",
                              value: "Football",
                            ),

                            const SizedBox(height: 16),

                            bookingDetail(
                              icon: Icons.timer_outlined,
                              title: "Duration",
                              value: timeDuration,
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF3FCF5),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Amount",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              "₹$amount",
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xff16A34A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: actionButton(
                        icon: Icons.near_me,
                        title: "Get Directions",
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: actionButton(icon: Icons.call, title: "Call Turf"),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: actionButton(icon: Icons.chat, title: "WhatsApp"),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyBookingsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "View Booking",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                outlinedActionButton(
                  icon: Icons.download_for_offline_outlined,
                  title: "Download Invoice",
                  onTap: () {},
                ),

                const SizedBox(height: 10),

                outlinedActionButton(
                  icon: Icons.share_outlined,
                  title: "Share Booking",
                  onTap: () {},
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => UserMainScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Go to Home",
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget bookingDetail({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Row(
    children: [
      Icon(icon, size: 22, color: Colors.grey.shade700),

      const SizedBox(width: 12),

      Expanded(
        child: Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ),

      Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

Widget actionButton({required IconData icon, required String title}) {
  return InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xff16A34A), size: 28),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}

Widget outlinedActionButton({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xff16A34A), size: 22),
      label: Text(
        title,
        style: const TextStyle(
          color: Color(0xff16A34A),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xff16A34A), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
