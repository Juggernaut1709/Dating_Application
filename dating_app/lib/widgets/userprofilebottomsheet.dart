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
        ).showSnackBar(const SnackBar(content: Text('✅ Friend request sent!')));
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❤️ You liked this match!')),
        );
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
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF74C0FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with gradient border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A5AE0), Color(0xFF74C0FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(width: 16),
            // Profile Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile['name'] ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Age: ${widget.profile['age'] ?? '-'}",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Like Button
            _buildActionButton(
              icon: Icons.favorite,
              onTap: () => _likeMatch(widget.profile['uid']),
              gradientColors: [Colors.pinkAccent, Colors.red],
              tooltip: "Like",
            ),
            const SizedBox(width: 8),
            // Friend Button
            _buildActionButton(
              icon: Icons.person_add,
              onTap: () => _sendFriendRequest(widget.profile['uid']),
              gradientColors: [Colors.teal, Colors.cyan],
              tooltip: "Add Friend",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
