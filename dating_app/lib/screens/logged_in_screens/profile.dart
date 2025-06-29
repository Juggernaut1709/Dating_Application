import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/widgets/circular_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String age = '';
  String gender = '';
  String email = '';
  String shortname = '';
  dynamic location;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final user = await UserService().getMyProfile();
    setState(() {
      name = user['name'] ?? '';
      age = user['age']?.toString() ?? '';
      gender = user['gender'] ?? '';
      email = user['email'] ?? '';
      shortname = user['shortName'] ?? '';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularLoader())
              : OrientationBuilder(
                builder: (context, orientation) {
                  final isPortrait = orientation == Orientation.portrait;
                  return Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Flex(
                          direction:
                              isPortrait ? Axis.vertical : Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person, size: 100),
                                const SizedBox(height: 40),
                                _buildProfileField('Name', name),
                                _buildProfileField('Age', age),
                                _buildProfileField('Gender', gender),
                                _buildProfileField('Email', email),
                                _buildProfileField('Unique ID', shortname),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text('$label: $value', style: const TextStyle(fontSize: 18)),
    );
  }
}
