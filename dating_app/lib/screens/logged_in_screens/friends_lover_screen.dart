import 'dart:developer' as dev;
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:dating_app/services/backend_service.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/widgets/circular_loader.dart';

class FriendsLoverScreen extends StatefulWidget {
  static const String routeName = '/friends_lover_screen';

  const FriendsLoverScreen({Key? key}) : super(key: key);

  @override
  State<FriendsLoverScreen> createState() => _FriendsLoverScreenState();
}

class _FriendsLoverScreenState extends State<FriendsLoverScreen> {
  bool _isLoading = true;
  List<Map<String, String>> _friendAndLoverList = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendsAndLovers();
  }

  Future<void> _fetchFriendsAndLovers() async {
    setState(() => _isLoading = true);
    try {
      final friendsAndLovers = await UserService().getFriendsAndLover();
      dev.log('Loaded: $friendsAndLovers');
      setState(() {
        _friendAndLoverList = List<Map<String, String>>.from(friendsAndLovers);
      });
    } catch (error) {
      ErrorService.showError(context, error.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmUnfriend(String friendId, String friendName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _buildUnfriendDialog(friendName),
    );
    if (confirm == true) {
      await _unfriendUser(friendId);
    }
  }

  Future<void> _unfriendUser(String friendId) async {
    final response = await unfriendUser(friendId);
    if (response == "success") {
      _showSnackBar('User has been unfriended.', Colors.green);
      _fetchFriendsAndLovers();
    } else {
      ErrorService.showError(context, response);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: bgColor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBackground(
        SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularLoader())
                        : _friendAndLoverList.isEmpty
                        ? _buildEmptyState()
                        : _buildFriendsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Your Friends',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            color: Colors.white.withOpacity(0.7),
            size: 90,
          ),
          const SizedBox(height: 20),
          Text(
            "No friends yet!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start connecting and make new matches 💖",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _friendAndLoverList.length,
      itemBuilder: (_, index) {
        final friend = _friendAndLoverList[index];
        return _buildFriendCard(friend);
      },
    );
  }

  Widget _buildFriendCard(Map<String, String> friend) {
    final id = friend['uid'] ?? 'Unknown';
    final name = friend['username'] ?? id;
    final role = friend['role'];
    final isLover = role == 'L';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isLover
                        ? Colors.pinkAccent.withOpacity(0.5)
                        : Colors.white.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isLover
                          ? Colors.pinkAccent.withOpacity(0.3)
                          : Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      isLover
                          ? Colors.pinkAccent.withOpacity(0.2)
                          : Colors.blueAccent.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.lightBlueAccent,
                  ),
                  tooltip: "Chat",
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/chat_screen',
                        arguments: {'friendId': id, 'friendName': name},
                      ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person_remove,
                    color: Colors.redAccent,
                  ),
                  tooltip: "Unfriend",
                  onPressed: () => _confirmUnfriend(id, name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnfriendDialog(String friendName) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a2a4a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      title: const Text(
        "Confirm Unfriend",
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        "Are you sure you want to unfriend $friendName?",
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Unfriend", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
