import 'package:flutter/material.dart';
import 'package:turfix/view/screens/user_screens/booking_confirmed_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xff16A34A);

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
          onPressed: () {},
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingConfirmedScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
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
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Green Field Arena",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        "Kozhikode, Kerala",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const BookingInfo(title: "Date", value: "20 May 2024"),

              const SizedBox(height: 25),

              BookingInfo(title: "Time", value: "05:00 PM - 06:00 PM"),
              const SizedBox(height: 25),

              const BookingInfo(title: "Sport", value: "Football"),

              const SizedBox(height: 25),

              const BookingInfo(title: "Total Duration", value: "1 Hour"),

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
                    '1200',
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

                  paymentTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "UPI",
                    subtitle: "Pay using any UPI app",
                    selected: true,
                  ),

                  paymentTile(
                    icon: Icons.credit_card_outlined,
                    title: "Credit / Debit Card",
                    subtitle: "Visa, MasterCard, Rupay",
                    selected: false,
                  ),

                  paymentTile(
                    icon: Icons.account_balance_wallet,
                    title: "Wallets",
                    subtitle: "Pay using wallet balance",
                    selected: false,
                  ),

                  paymentTile(
                    icon: Icons.account_balance_outlined,
                    title: "Net Banking",
                    subtitle: "All major banks supported",
                    selected: false,
                  ),

                  paymentTile(
                    icon: Icons.payments_outlined,
                    title: "Pay at Venue",
                    subtitle: "Pay at the time of visit",
                    selected: false,
                  ),
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

Widget paymentTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required bool selected,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: selected ? const Color(0xffF2FCF5) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: selected ? const Color(0xff16A34A) : Colors.grey.shade300,
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
          child: Icon(icon, color: Colors.black87),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),

        Radio<bool>(
          value: true,
          groupValue: selected,
          activeColor: const Color(0xff16A34A),
          onChanged: (_) {},
        ),
      ],
    ),
  );
}
