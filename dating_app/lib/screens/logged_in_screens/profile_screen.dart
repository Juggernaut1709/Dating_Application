import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/widgets/circular_loader.dart';

class ProfileScreen extends StatefulWidget {
  final String routeName = '/profile_screen';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    final user = await UserService().getMyProfile();
    if (mounted) {
      setState(() {
        name = user['name'] ?? '';
        age = user['age']?.toString() ?? '';
        gender = user['gender'] ?? '';
        email = user['email'] ?? '';
        shortname = user['shortName'] ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Fixes potential clipping
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularLoader())
                : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          _buildAppBar(),
                          const SizedBox(height: 24),
                          _buildProfileHeader(),
                          const SizedBox(height: 32),
                          _buildInfoCard(),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () {
            print("Navigate to Edit Profile Screen");
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BF8F).withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: CircleAvatar(
              radius: 58,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.person,
                size: 58,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$age years old',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildProfileDetailRow(
                icon: Icons.person_outline,
                label: 'Gender',
                value: gender,
              ),
              const Divider(color: Colors.white12, height: 24),
              _buildProfileDetailRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email,
              ),
              const Divider(color: Colors.white12, height: 24),
              _buildProfileDetailRow(
                icon: Icons.alternate_email,
                label: 'Unique ID',
                value: shortname,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00BF8F), size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
