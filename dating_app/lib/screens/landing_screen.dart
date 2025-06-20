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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserService().handleLandingNavigation(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
