import 'dart:ui';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/widgets/friend_request.dart';
import 'package:dating_app/widgets/matching_profile.dart';
import 'package:dating_app/widgets/userprofilebottomsheet.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String routeName = '/home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _userIdController = TextEditingController();
  int _distance = 1001;

  void _signOut() async {
    await AuthService().signOut();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Successfully signed out')));
      Navigator.pushReplacementNamed(context, '/auth_screen');
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
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E2DE2), // brighter purple
                  Color(0xFF4A00E0), // deep purple
                  Color(0xFF2575fc), // light blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                _buildControlPanel(),
                Expanded(
                  child: MatchingProfile(
                    key: ValueKey(_distance),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '💜 VibeMatch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Row(
                  children: [
                    _circleIconButton(
                      icon: Icons.notifications_none_rounded,
                      onPressed:
                          () => showDialog(
                            context: context,
                            builder: (_) => const RequestsDialog(),
                          ),
                    ),
                    const SizedBox(width: 8),
                    _circleIconButton(
                      icon: Icons.logout_rounded,
                      onPressed: _signOut,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
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
      height: 52,
      child: TextField(
        controller: _userIdController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: '🔍 Search by User ID...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.75)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          suffixIcon: GestureDetector(
            onTap: () => _onSearchSubmit(_userIdController.text),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.search, color: Colors.white),
            ),
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
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF8E2DE2),
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: const Color(0xFF2575fc),
            overlayColor: const Color(0xFF8E2DE2).withOpacity(0.2),
          ),
          child: Slider(
            value: _distance.toDouble(),
            min: 1,
            max: 1001,
            onChanged: (value) {
              setState(() {
                _distance = value.round();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF2575fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: BottomAppBar(
          color: Colors.white.withOpacity(0.08),
          elevation: 8,
          child: IconTheme(
            data: const IconThemeData(color: Colors.white, size: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.people_alt_rounded),
                  tooltip: 'Friends',
                  onPressed: () {
                    Navigator.pushNamed(context, '/friends_lover_screen');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.question_mark_rounded),
                  tooltip: 'Questions',
                  onPressed: () {
                    Navigator.pushNamed(context, '/onboarding_screen');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.music_note_rounded),
                  tooltip: 'Song suggestions',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded),
                  tooltip: 'Profile',
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile_screen');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
