import 'dart:ui';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/widgets/friend_request.dart';
import 'package:dating_app/widgets/matching_profile.dart';
import 'package:dating_app/widgets/userprofilebottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  final String routeName = '/home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _userIdController = TextEditingController();
  int _distance = 1001; // Default distance

  void _signOut() async {
    await AuthService().signOut();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Successfully signed out')));
      Navigator.pushReplacementNamed(context, '/auth_screen');
      print("Navigating to Auth Screen");
    }
  }

  void _onSearchSubmit(String userId) async {
    if (userId.isNotEmpty) {
      Object? result = await UserService().retrieveUserProfile(userId);
      if (!mounted) return;

      if (result is String) {
        ErrorService.showError(context, result);
      } else if (result is Map<String, dynamic>) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => UserProfileBottomSheet(profile: result),
        );
      }
    } else {
      ErrorService.showError(context, 'Please enter a user ID to search');
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            bottom: false, // Avoid double padding with custom bottom bar
            child: Column(
              children: [
                _buildAppBar(),
                _buildControlPanel(),
                Expanded(
                  child: MatchingProfile(
                    key: ValueKey(_distance), // Rebuilds when distance changes
                    distance: _distance,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'VibeMatch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed:
                    () => showDialog(
                      context: context,
                      builder: (_) => const FriendRequestsDialog(),
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                onPressed: _signOut,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildDistanceSlider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _userIdController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by User ID...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF00BF8F)),
            onPressed: () => _onSearchSubmit(_userIdController.text),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distance: ${_distance == 1001 ? 'Any' : 'Up to $_distance km'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: _distance.toDouble(),
          min: 1,
          max: 1001,
          activeColor: const Color(0xFF00BF8F),
          inactiveColor: Colors.white.withOpacity(0.2),
          onChanged: (value) {
            setState(() {
              _distance = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: const Color(0xFF16213e).withOpacity(0.95),
      shape: const CircularNotchedRectangle(),
      elevation: 8,
      child: IconTheme(
        data: IconThemeData(color: Colors.white.withOpacity(0.8), size: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Friends',
              onPressed: () {
                Navigator.pushNamed(context, '/friends_lover_screen');
              },
            ),
            IconButton(
              icon: const Icon(Icons.question_mark),
              tooltip: 'Questions',
              onPressed: () {
                Navigator.pushNamed(context, '/onboarding_screen');
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.pushNamed(context, '/profile_screen');
              },
            ),
          ],
        ),
      ),
    );
  }
}
