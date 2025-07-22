import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class ChatService {
  WebSocketChannel? _channel;
  final String userId;

  ChatService(this.userId);

  void connectToWebSocket(
    Function(Map<String, dynamic>) onMessageReceived,
  ) async {
    final urlSnapshot =
        await FirebaseFirestore.instance.collection('url').doc('url').get();
    final String url = (urlSnapshot.data())!['url'];
    final String wssUrl = url.replaceFirst('https', 'wss');

    _channel = WebSocketChannel.connect(Uri.parse('$wssUrl/ws/$userId'));

    _channel!.stream.listen((data) {
      final decoded = jsonDecode(data);
      onMessageReceived(decoded);
    });
  }

  void sendMessage(String senderId, String receiverId, String message) {
    final data = {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
    };
    _channel?.sink.add(jsonEncode(data));
  }

  void disconnect() {
    _channel?.sink.close();
  }

  Future<List<Map<String, dynamic>>> fetchChatHistory(
    String senderId,
    String receiverId,
  ) async {
    final urlSnapshot =
        await FirebaseFirestore.instance.collection('url').doc('url').get();
    final String url = (urlSnapshot.data())!['url'];

    final response = await http.get(
      Uri.parse(
        '$url/chat/history?sender_id=$senderId&receiver_id=$receiverId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userId', // Using userId as token
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch chat history');
    }
  }
}
