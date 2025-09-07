import 'package:dating_app/screens/auth_screen.dart';
import 'package:dating_app/screens/landing_screen.dart';
import 'package:dating_app/screens/logged_in_screens/chat_screen.dart';
import 'package:dating_app/screens/logged_in_screens/friends_lover_screen.dart';
import 'package:dating_app/screens/logged_in_screens/home_screen.dart';
import 'package:dating_app/screens/logged_in_screens/profile_screen.dart';
import 'package:dating_app/screens/logged_in_screens/song_screen.dart';
import 'package:dating_app/screens/onboarding_screen.dart';
import 'package:dating_app/screens/profile_setting_screen.dart';
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
        '/profile_setting_screen': (context) => const ProfileSettingScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/profile_screen': (context) => const ProfileScreen(),
        '/friends_lover_screen': (context) => const FriendsLoverScreen(),
        '/chat_screen': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final friendId =
              (args is Map<String, String>) ? args['friendId'] ?? '' : '';
          final friendName =
              (args is Map<String, String>) ? args['friendName'] ?? '' : '';
          return ChatScreen(friendId: friendId, friendName: friendName);
        },
        '/song_screen': (context) => const SongScreen(),
      },
    );
  }
}
