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
    if (matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return PageView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Name: ${match[1]}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Short name: ${match[2]}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Age: ${match[3]}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Similarity: ${double.parse((match[4] * 100).toStringAsFixed(2))}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_add),
                            onPressed: () {
                              _sendFriendRequest(match[0]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite),
                            onPressed: () {
                              _likeMatch(match[0]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
