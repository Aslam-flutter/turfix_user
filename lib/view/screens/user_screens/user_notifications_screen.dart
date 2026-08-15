import 'package:flutter/material.dart';

class UserNotificationsScreen extends StatelessWidget {
  const UserNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black,
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Mark all as read",
                  style: TextStyle(
                    color: Color(0xff16A34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                children: const [
                  NotificationTile(
                    icon: Icons.verified,
                    iconColor: Color(0xff16A34A),
                    title: "Booking Confirmed",
                    subtitle: "Green Field Arena • 20 May • 10:30 AM",
                    time: "10:30 AM",
                  ),

                  SizedBox(height: 18),

                  NotificationTile(
                    icon: Icons.schedule,
                    iconColor: Color(0xff16A34A),
                    title: "Booking Reminder",
                    subtitle: "Your booking starts at 06:00 PM",
                    time: "09:00 AM",
                  ),

                  SizedBox(height: 18),

                  NotificationTile(
                    icon: Icons.local_offer,
                    iconColor: Color(0xff16A34A),
                    title: "Offer For You",
                    subtitle: "Get 30% off on all bookings",
                    time: "Yesterday",
                  ),

                  SizedBox(height: 18),

                  NotificationTile(
                    icon: Icons.stadium,
                    iconColor: Color(0xff16A34A),
                    title: "New Turf Added",
                    subtitle: "Victory Ground is now available on Turfix",
                    time: "2 days ago",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xffF7FCF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          if (!isRead)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xff16A34A),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
