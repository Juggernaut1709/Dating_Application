import 'package:dating_app/services/backend_service.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:flutter/material.dart';

class UserProfileBottomSheet extends StatefulWidget {
  final Map<String, dynamic> profile;

  const UserProfileBottomSheet({Key? key, required this.profile})
    : super(key: key);

  @override
  State<UserProfileBottomSheet> createState() => _UserProfileBottomSheetState();
}

class _UserProfileBottomSheetState extends State<UserProfileBottomSheet> {
  Future<void> _sendFriendRequest(friendId) async {
    try {
      String response = await sendFriendRequest(friendId);
      if (response == "success") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sent a friend request')));
      } else {
        ErrorService.showError(context, response);
      }
    } catch (e) {
      ErrorService.showError(context, "Failed to send friend request.");
    }
  }

  Future<void> _likeMatch(matchId) async {
    try {
      String response = await sendLoveRequest(matchId);
      if (response == "success") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Liked the match')));
      } else {
        ErrorService.showError(context, response);
      }
    } catch (e) {
      ErrorService.showError(context, "Failed to like match.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 72,
                height: 72,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 40),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name : ${widget.profile['name']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Age : ${widget.profile['age']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              color: const Color.fromARGB(255, 209, 25, 12),
              onPressed: () {
                _likeMatch(widget.profile['uid']);
              },
              tooltip: 'Add Interest',
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              color: const Color.fromARGB(255, 8, 158, 158),
              onPressed: () {
                _sendFriendRequest(widget.profile['uid']);
              },
              tooltip: 'Add Friend',
            ),
          ],
        ),
      ),
    );
  }
}
