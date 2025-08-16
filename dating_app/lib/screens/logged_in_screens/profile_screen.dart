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
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
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
        _buildGlassButton(
          icon: Icons.arrow_back_ios,
          onTap: () => Navigator.of(context).pop(),
        ),
        const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildGlassButton(
          icon: Icons.edit_outlined,
          onTap: () {
            print("Navigate to Edit Profile Screen");
          },
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: Colors.white.withOpacity(0.2),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
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
                color: Colors.white.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white.withOpacity(0.85),
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
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
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
              const Divider(color: Colors.white38, height: 24),
              _buildProfileDetailRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email,
              ),
              const Divider(color: Colors.white38, height: 24),
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
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
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
