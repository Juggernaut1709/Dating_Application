import 'package:dating_app/services/backend_service.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class MatchingProfile extends StatefulWidget {
  const MatchingProfile({Key? key, required this.distance}) : super(key: key);

  final int distance;

  @override
  _MatchingProfileState createState() => _MatchingProfileState();
}

class _MatchingProfileState extends State<MatchingProfile> {
  List<List<dynamic>> matches = [];

  @override
  void initState() {
    super.initState();
    dev.log('MatchingProfile initialized');
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final result = await sendMatchRequest(widget.distance);
    dev.log('Matches loaded: ${result.length} matches found');
    setState(() {
      matches = result;
    });
  }

  Future<void> _sendFriendRequest(matchId) async {
    try {
      String response = await sendFriendRequest(matchId);
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
    if (matches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF74C0FC)], // purple → light blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: PageView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        match[1], // Name
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A5AE0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@${match[2]}', // Short name
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Age: ${match[3]}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Similarity: ${double.parse((match[4] * 100).toStringAsFixed(2))}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildGradientButton(
                            icon: Icons.person_add,
                            label: "Friend",
                            onTap: () => _sendFriendRequest(match[0]),
                          ),
                          _buildGradientButton(
                            icon: Icons.favorite,
                            label: "Like",
                            onTap: () => _likeMatch(match[0]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
      ),
      icon: ShaderMask(
        shaderCallback:
            (bounds) => const LinearGradient(
              colors: [Color(0xFF6A5AE0), Color(0xFF74C0FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
