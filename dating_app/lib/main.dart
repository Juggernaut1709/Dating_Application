import 'package:dating_app/screens/auth_screen.dart';
import 'package:dating_app/screens/landing_screen.dart';
import 'package:dating_app/screens/logged_in_screens/home_screen.dart';
import 'package:dating_app/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/auth_screen': (context) => const AuthScreen(),
        '/onboarding_screen': (context) => const OnboardingScreen(),
        '/home_screen': (context) => const HomeScreen(),
      },
    );
  }
}
