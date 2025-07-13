import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final String routeName = '/friends_screen';

  bool _isLoading = false;

  void show_friends() {
    _isLoading = true;
  }

  @override
  void initState() {
    super.initState();
    show_friends();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
