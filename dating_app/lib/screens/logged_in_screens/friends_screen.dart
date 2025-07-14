import 'package:dating_app/services/backend_service.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/widgets/circular_loader.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final String routeName = '/friends_screen';
  bool _isLoading = true;
  List<String> _friendList = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
    });
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
            title: const Text("Confirm Unfriend"),
            content: Text("Are you sure you want to unfriend $friendId?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text("Unfriend"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      String response = await unfriendUser(friendId);
      if (response == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User has been unfriended.')),
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
      appBar: AppBar(title: const Text("Your Friends"), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularLoader())
              : _friendList.isEmpty
              ? const Center(child: Text("You have no friends yet."))
              : ListView.builder(
                itemCount: _friendList.length,
                itemBuilder: (context, index) {
                  final friendId = _friendList[index];
                  return ListTile(
                    title: Text("Friend ID: $friendId"),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: "Unfriend",
                      color: Colors.red,
                      onPressed: () => _confirmUnfriend(friendId),
                    ),
                  );
                },
              ),
    );
  }
}
