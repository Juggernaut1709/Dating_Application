import 'package:dating_app/services/matching_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class MatchingProfile extends StatefulWidget {
  const MatchingProfile({Key? key}) : super(key: key);

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
    final result = await sendMatchRequest();
    dev.log('Matches loaded: ${result.length} matches found');
    setState(() {
      matches = result;
    });
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
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Name: ${match[0]}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Short name: ${match[1]}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Age: ${match[2]}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Similarity: ${match[3]}%',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
