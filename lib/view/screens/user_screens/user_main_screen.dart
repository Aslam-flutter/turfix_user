import 'package:flutter/material.dart';
import 'package:turfix/view/screens/user_screens/my_booking_screen.dart';
import 'package:turfix/view/screens/user_screens/search_turf_screen.dart';
import 'package:turfix/view/screens/user_screens/user_home_screen.dart';
import 'package:turfix/view/screens/user_screens/user_profile_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    Center(child: UserHomeScreen()),
    Center(child: MyBookingsScreen()),
    Center(child: SearchTurfScreen()),
    Center(child: UserProfileScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xff111827),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                navItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  index: 0,
                  activeColor: primary,
                ),

                navItem(
                  icon: Icons.calendar_today_outlined,
                  label: "Bookings",
                  index: 1,
                  activeColor: primary,
                ),

                navItem(
                  icon: Icons.explore_outlined,
                  label: "Explore",
                  index: 2,
                  activeColor: primary,
                ),

                navItem(
                  icon: Icons.person_outline,
                  label: "Profile",
                  index: 3,
                  activeColor: primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
  }) {
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 25,
                color: selected ? activeColor : Colors.white70,
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  color: selected ? activeColor : Colors.white70,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
