import 'package:dio/dio.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

final dio = Dio();

Future<List<List>> sendMatchRequest() async {
  final userService = UserService();
  final currentUser = await userService.getCurrentUser();
  dev.log('Current user: ${currentUser?.uid}');

  final userDoc =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

  final onboardingAnswers = userDoc.data()?['onboarding_answers'] ?? [];

  final data = {
    'user_id': currentUser.uid,
    'onboarding_answers': onboardingAnswers,
  };

  final urlSnapshot =
      await FirebaseFirestore.instance.collection('url').doc('url').get();
  final String url = (urlSnapshot.data())!['url'] + "/matches";

  dev.log('Sending match request with data: $data');
  final response = await dio.post(
    url,
    data: data,
    options: Options(headers: {"Content-Type": "application/json"}),
  );
  final List<dynamic> matches = response.data;

  List<List<dynamic>> result = [];

  for (var match in matches) {
    final userId = match[0];
    final similarity = match[1];

    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userData = userSnapshot.data();

    if (userData != null) {
      final username = userData['username'] ?? '';
      final shortname = userData['shortName'] ?? '';
      final age = userData['age'] ?? '';
      result.add([username, shortname, age, similarity]);
    }
  }

  dev.log('Matches found: ${result.length}');
  return result;
}

Future<String> sendFriendRequest(String friend) async {
  final userService = UserService();
  final currentUser = await userService.getCurrentUser();

  final data = {'user_id': currentUser!.uid, 'friend_id': friend};

  final urlSnapshot =
      await FirebaseFirestore.instance.collection('url').doc('url').get();
  final String url = (urlSnapshot.data())!['url'] + "/send_friend_request";

  dev.log('Sending friend request with data: $data');
  final response = await dio.post(
    url,
    data: data,
    options: Options(headers: {"Content-Type": "application/json"}),
  );
  final String result = response.data;
  return result;
}
