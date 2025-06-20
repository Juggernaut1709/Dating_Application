import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nanoid/nanoid.dart';
import 'dart:developer' as dev;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final UserCredential _userCredential;

  Future<String> signup(String username, String email, String password) async {
    try {
      _userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _userCredential.user?.updateDisplayName(username);
      await _userCredential.user?.sendEmailVerification();
      await addUserToFirestore(_userCredential.user!.uid, username, email);
      dev.log("User signed up: ${_userCredential.user?.uid}");
      return "Success. Please check your email to verify your account.";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return "Weak password";
      if (e.code == 'email-already-in-use') return "Email already in use";
      return e.message ?? "Signup failed";
    } catch (e) {
      return "Signup error";
    }
  }

  Future<String> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        return "Please verify your email before signing in.";
      }
      dev.log("User signed in: ${user?.uid}");
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "Email not registered";
      if (e.code == 'wrong-password') return "Invalid password";
      return e.message ?? "Sign-in failed";
    } catch (e) {
      return "Login error";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    dev.log("User signed out");
  }

  Future<void> addUserToFirestore(
    String uid,
    String username,
    String email,
  ) async {
    String shortName = await createShortName(username);

    await _firestore.collection('users').doc(uid).set({
      "username": username,
      "email": email,
      "shortName": shortName,
      "age": 0,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await _firestore.collection('usershortnames').doc(shortName).set({
      "uid": uid,
    });

    dev.log("User added to Firestore with shortName: $shortName");
  }

  Future<String> createShortName(String username) async {
    String shortName;
    bool isUnique = false;

    do {
      final suffix = nanoid(7);
      shortName = "${username.toLowerCase()}_$suffix";
      final snapshot =
          await _firestore.collection('usershortnames').doc(shortName).get();
      isUnique = !snapshot.exists;
    } while (!isUnique);

    return shortName;
  }
}
