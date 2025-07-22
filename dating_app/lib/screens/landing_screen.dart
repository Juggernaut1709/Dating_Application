import 'package:dating_app/widgets/circular_loader.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';

class LandingScreen extends StatefulWidget {
  final String routeName = '/landing_screen';
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // This ensures that the navigation logic is called after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserService().handleLandingNavigation(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply the same gradient background as the other screens
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add the app logo for a branded loading experience
              const Icon(Icons.music_note, color: Color(0xFF00BF8F), size: 60),
              const SizedBox(height: 20),
              const Text(
                "VibeMatch",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Use the themed circular loader
              const CircularLoader(size: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}
