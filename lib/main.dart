import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix/firebase_options.dart';
import 'package:turfix/view/auth/splash_screen.dart';
import 'package:turfix/view_model/bookig_provider.dart';
import 'package:turfix/view_model/common_provider.dart';
import 'package:turfix/view_model/favorite_provider.dart';
import 'package:turfix/view_model/location_provider.dart';
import 'package:turfix/view_model/nearby_turf_provider.dart';
import 'package:turfix/view_model/payment_provider.dart';
import 'package:turfix/view_model/search_turf_provider.dart';
import 'package:turfix/view_model/slot_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CommonProvider()),
        ChangeNotifierProvider(create: (context) => BookingProvider()),
        ChangeNotifierProvider(create: (context) => SlotProvider()),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => NearbyTurfProvider()),
        ChangeNotifierProvider(
          create: (context) => FavoriteProvider()..loadFavorites(),
        ),
        ChangeNotifierProvider(create: (_) => SearchTurfProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
