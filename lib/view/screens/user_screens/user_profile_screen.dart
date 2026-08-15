import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfix/core/services/auth_services.dart';
import 'package:turfix/view/screens/user_screens/favorite_screen.dart';
import 'package:turfix/view/screens/user_screens/my_booking_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final userDetails = asyncSnapshot.data;

            if (userDetails == null) {
              return Expanded(child: Center(child: Text('No details found')));
            }

            return Column(
              children: [
                const SizedBox(height: 10),

                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      "https://encrypted-tbn.gstatic.com/images?q=tbn:ANd9GcRy4zO0deqi7qCTBBARyNCfxo4yttR5ezLuUOR9_55sCQ&s=10",
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.black,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  userDetails['name'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  userDetails['phone'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                ),

                const SizedBox(height: 2),

                Text(
                  userDetails['email'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                ),

                const SizedBox(height: 35),

                ProfileMenuTile(
                  icon: Icons.calendar_month_outlined,
                  title: "My Bookings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyBookingsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                ProfileMenuTile(
                  icon: Icons.favorite_border,
                  title: "Favorites",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoritesScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // ProfileMenuTile(
                //   icon: Icons.payment_outlined,
                //   title: "Payment Methods",
                //   onTap: () {},
                // ),

                // const SizedBox(height: 14),
                ProfileMenuTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),

                const SizedBox(height: 14),

                ProfileMenuTile(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {},
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      AuthServices().logOut(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
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
            children: [
              Icon(icon, size: 24, color: Colors.grey.shade700),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
