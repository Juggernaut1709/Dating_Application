import 'dart:io';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/widgets/friend_request.dart';
import 'package:dating_app/widgets/matching_profile.dart';
import 'package:dating_app/widgets/userprofilebottomsheet.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String routeName = '/home_screen';

  final TextEditingController _userIdController = TextEditingController();

  void _signOut(BuildContext context) {
    AuthService()
        .signOut()
        .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully signed out')),
          );
        })
        .catchError((error) {
          ErrorService.showError(context, 'Error signing out: $error');
        });
    sleep(const Duration(seconds: 1));
    Navigator.pushReplacementNamed(context, '/auth_screen');
  }

  void _onSearchSubmit(String userId) async {
    if (userId.isNotEmpty) {
      Object? result = await UserService().retrieveUserProfile(userId);

      if (result is String) {
        ErrorService.showError(context, result);
      } else if (result is Map<String, dynamic>) {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          builder: (context) {
            return UserProfileBottomSheet(profile: result);
          },
        );
      } else {
        ErrorService.showError(context, 'User not found');
      }
    } else {
      ErrorService.showError(context, 'Please enter a user ID to search');
    }
  }

  MatchingProfile _callMatch() {
    return MatchingProfile();
  }

  @override
  void initState() {
    super.initState();
    _callMatch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.notifications),
          tooltip: 'Notifications',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const FriendRequestsDialog(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _userIdController.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for love (or friendship)...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () => _onSearchSubmit(_userIdController.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _callMatch()),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Chat',
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Friends',
              onPressed: () {
                Navigator.pushNamed(context, '/friends_screen');
              },
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
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
