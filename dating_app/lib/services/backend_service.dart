import 'package:dio/dio.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

final dio = Dio();

Future<List<List>> sendMatchRequest(int distance) async {
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
    'distance': distance,
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
    result.add([
      match['uid'],
      match['username'],
      match['shortName'],
      match['age'],
      match['similarity'],
    ]);
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

  final result = response.data as Map<String, dynamic>;
  return result['message'];
}

Future<String> sendLoveRequest(String matchId) async {
  final userService = UserService();
  final currentUser = await userService.getCurrentUser();

  final data = {'user_id': currentUser!.uid, 'match_id': matchId};

  final urlSnapshot =
      await FirebaseFirestore.instance.collection('url').doc('url').get();
  final String url = (urlSnapshot.data())!['url'] + "/send_love_request";

  dev.log('Sending love request with data: $data');
  final response = await dio.post(
    url,
    data: data,
    options: Options(headers: {"Content-Type": "application/json"}),
  );

  final result = response.data as Map<String, dynamic>;
  return result['message'];
}

Future<String> requestResponse(receiver, role, decision) async {
  final userService = UserService();
  final currentUser = await userService.getCurrentUser();

  final data = {
    'user_id': currentUser!.uid,
    'receiver_id': receiver,
    'role': role,
    'decision': decision,
  };

  final urlSnapshot =
      await FirebaseFirestore.instance.collection('url').doc('url').get();
  final String url = (urlSnapshot.data())!['url'] + "/request_response";

  dev.log('Sending request response with data: $data');
  final response = await dio.post(
    url,
    data: data,
    options: Options(headers: {"Content-Type": "application/json"}),
  );

  final result = response.data as Map<String, dynamic>;
  return result['message'];
}

Future<String> unfriendUser(String uid) async {
  final userService = UserService();
  final currentUser = await userService.getCurrentUser();
  if (currentUser == null) return "User not found";

  final urlSnapshot =
      await FirebaseFirestore.instance.collection('url').doc('url').get();
  final String url = (urlSnapshot.data())!['url'] + "/unfriend_user";

  final response = await dio.post(
    url,
    data: {'user_id': currentUser.uid, 'friend_id': uid},
    options: Options(headers: {"Content-Type": "application/json"}),
  );

  final result = response.data as Map<String, dynamic>;
  return result['message'];
}
