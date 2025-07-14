import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;

  const ChatScreen({super.key, required this.friendId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String routeName = '/chat_screen';
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(child: Text('Chat with friend ID: ${widget.friendId}')),
    );
  }
}
