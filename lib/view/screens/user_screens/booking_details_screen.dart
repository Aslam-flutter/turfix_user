import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // const primary = Color(0xff16A34A);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Cancel Booking",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Turf Image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Green Field Arena",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              "Kozhikode, Kerala",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),

            const SizedBox(height: 30),

            const Row(
              children: [
                Expanded(
                  child: BookingInfo(title: "Date", value: "20 May 2026"),
                ),

                Expanded(
                  child: BookingInfo(
                    title: "Time",
                    value: "06:00 PM - 07:00 PM",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Row(
              children: [
                Expanded(
                  child: BookingInfo(title: "Sport", value: "Football"),
                ),

                Expanded(
                  child: BookingInfo(title: "Duration", value: "1 Hour"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 25),

            const BookingInfo(title: "Booking ID", value: "TRX12345678"),

            const SizedBox(height: 20),

            const BookingInfo(
              title: "Booked On",
              value: "18 May 2026 • 10:30 AM",
            ),
          ],
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
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),

        const SizedBox(height: 8),

        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
