import 'dart:ui';
import 'package:dating_app/services/backend_service.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/widgets/circular_loader.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';

class FriendsLoverScreen extends StatefulWidget {
  final String routeName = '/friends_lover_screen';
  const FriendsLoverScreen({Key? key}) : super(key: key);

  @override
  State<FriendsLoverScreen> createState() => _FriendsLoverScreenState();
}

class _FriendsLoverScreenState extends State<FriendsLoverScreen> {
  bool _isLoading = true;
  List<String> _friendList = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    final List<dynamic> friends = await UserService().getFriends();
    setState(() {
      _friendList = List<String>.from(friends);
      _isLoading = false;
    });
  }

  Future<void> _confirmUnfriend(String friendId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF16213e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: const Text(
              "Confirm Unfriend",
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              "Are you sure you want to unfriend $friendId?",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Unfriend",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      String response = await unfriendUser(friendId);
      if (response == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User has been unfriended.'),
            backgroundColor: Color(0xFF00BF8F),
          ),
        );
      } else {
        ErrorService.showError(context, response);
      }
      _loadFriends();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularLoader())
                        : _friendList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _friendList.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildFriendCard(_friendList[index]),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance layout
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
            Icons.sentiment_dissatisfied,
            color: Colors.white.withOpacity(0.5),
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            "You have no friends yet.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(String friendId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white70, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Friend ID: $friendId",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF00BF8F),
                  ),
                  tooltip: "Chat",
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/chat_screen',
                        arguments: friendId,
                      ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person_remove,
                    color: Colors.redAccent,
                  ),
                  tooltip: "Unfriend",
                  onPressed: () => _confirmUnfriend(friendId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
