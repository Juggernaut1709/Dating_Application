import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<int> getUserAge(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['age'] ?? 0;
    } catch (e) {
      debugPrint('Error getting age: $e');
      return 0;
    }
  }

  Future<bool> isUserProfileComplete(String uid) async {
    final age = await getUserAge(uid);
    return age > 0;
  }

  Future<void> completeUserProfile(
    BuildContext context, {
    required int age,
    required String gender,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'age': age,
        'gender': gender,
      });

      Navigator.pushReplacementNamed(context, '/home_screen');
    } catch (e) {
      dev.log('Error completing profile: $e');
    }
  }

  Future<void> handleLandingNavigation(BuildContext context) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        Navigator.pushReplacementNamed(context, '/auth_screen');
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists || doc.data()?['age'] == null || doc['age'] == 0) {
        Navigator.pushReplacementNamed(context, '/onboarding_screen');
      } else {
        Navigator.pushReplacementNamed(context, '/home_screen');
      }
    } catch (e) {
      dev.log('Navigation error: $e');
    }
  }

  Future<void> saveOnboardingAnswers(List<double> answers) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'onboarding_answers': answers,
      });
    } catch (e) {
      dev.log('Error saving onboarding answers: $e');
    }
  }

  Future<void> saveProfile(
    int age,
    String gender,
    double lat,
    double long,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'age': age,
        'gender': gender,
        'location': {'latitude': lat, 'longitude': long},
      });
      dev.log('Profile saved successfully for user: ${user.uid}');
    } catch (e) {
      dev.log('Error saving profile: $e');
    }
  }

  Future<Object?> retrieveUserProfile(String uid) async {
    try {
      final shortnameDoc =
          await _firestore.collection('usershortnames').doc(uid).get();
      if (shortnameDoc.exists) {
        final userId = shortnameDoc.data()?['uid'];
        final currentUser = _auth.currentUser;
        if (userId == currentUser?.uid) {
          return "You narcissist!!!.";
        }
        if (userId != null) {
          final userDoc =
              await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            final data = userDoc.data();
            dev.log('User profile retrieved: $data');
            return {'name': data?['username'], 'age': data?['age']};
          }
        }
        return null;
      }
    } catch (e) {
      dev.log('Error retrieving user profile: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      throw Exception('User profile does not exist');
    }

    return {
      'name': doc.data()?['username'] ?? '',
      'age': doc.data()?['age'] ?? 0,
      'gender': doc.data()?['gender'] ?? '',
      'email': doc.data()?['email'] ?? '',
      'shortName': doc.data()?['shortName'] ?? '',
    };
  }
}
