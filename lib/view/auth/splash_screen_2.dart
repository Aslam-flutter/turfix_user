import 'package:flutter/material.dart';
import 'package:turfix/core/constants/app_constants.dart';
import 'package:turfix/view/auth/login_screen.dart';
import 'package:turfix/view/auth/register_screen.dart';
import 'package:turfix/widgets/custom_sized_box.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {
  final sports = [
    "assets/images/football.png",
    "assets/images/cricket.png",
    "assets/images/badminton .png",
    "assets/images/volleyball.png",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Welcome to",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Turfix",
              style: TextStyle(
                color: AppConstants.darkGreen,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          sh(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Back your favorite turf",
              style: TextStyle(
                color: AppConstants.gray,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "anytime, anywhere",
              style: TextStyle(
                color: AppConstants.gray,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          sh(10),
          SizedBox(
            height: 280,
            child: PageView.builder(
              itemCount: sports.length,
              controller: PageController(viewportFraction: 0.78),
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(sports[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          sh(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MaterialButton(
              height: 60,
              minWidth: double.infinity,
              color: AppConstants.darkGreen,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                  (route) => false,
                );
              },
              child: Text(
                "Get Started",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          sh(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MaterialButton(
              height: 60,
              minWidth: double.infinity,
              textColor: Colors.black,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                "Login",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
