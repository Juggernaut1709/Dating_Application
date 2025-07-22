import 'dart:ui';
import 'package:dating_app/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';

class ChatScreen extends StatefulWidget {
  final String routeName = '/chat_screen';
  final String friendId;

  const ChatScreen({Key? key, required this.friendId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService chatService;
  List<Map<String, dynamic>> messages = [];
  late String userId;
  String friendName = 'Loading...';

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final user = await UserService().getCurrentUser();
    if (user == null) return;
    userId = user.uid;

    chatService = ChatService(userId);

    final history = await chatService.fetchChatHistory(userId, widget.friendId);
    if (mounted) {
      setState(() {
        messages = history;
      });
    }

    chatService.connectToWebSocket((msg) {
      if (mounted) {
        setState(() {
          messages.add(msg);
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    chatService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      chatService.sendMessage(userId, widget.friendId, text);
      setState(() {
        messages.add({
          "sender_id": userId,
          "message": text,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _messageController.clear();
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMine = msg['sender_id'] == userId;
                    return _buildMessageBubble(isMine, msg['message']);
                  },
                ),
              ),
              const SizedBox(height: 4),
              _buildMessageComposer(),
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
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friendName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isMine, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient:
                isMine
                    ? const LinearGradient(
                      colors: [Color(0xFF00BF8F), Color(0xFF009A75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: isMine ? null : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft:
                  isMine ? const Radius.circular(18) : const Radius.circular(6),
              bottomRight:
                  isMine ? const Radius.circular(6) : const Radius.circular(18),
            ),
            boxShadow:
                isMine
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : [],
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00BF8F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
