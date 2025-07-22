import 'dart:ui';

import 'package:dating_app/services/req_permission.dart';
import 'package:dating_app/widgets/confirm_button.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/services/location_service.dart';
import 'package:dating_app/widgets/location_map.dart';
import 'package:latlong2/latlong.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({Key? key}) : super(key: key);
  final String routeName = '/profile_setting_screen';

  @override
  _ProfileSettingScreenState createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  int? _age = 25;
  String? _gender;
  LatLng? _selectedLocation;
  String? _locationAddress;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await requestLocationPermission();
    await _getCurrentLocation();
  }

  Future<void> _saveProfile() async {
    if (_age == null || _gender == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await UserService().saveProfile(
      _age!,
      _gender!,
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
    );
    setState(() => _isLoading = false);
    // In a real app: Navigator.pushReplacementNamed(context, '/home_screen');
    print("Profile saved! Navigating to Home Screen.");
  }

  Future<void> _getCurrentLocation() async {
    final service = LocationService();
    final location = await service.getCurrentLocation();
    final latLng = LatLng(location.latitude, location.longitude);
    await _updateLocation(latLng);
  }

  Future<void> _updateLocation(LatLng latLng) async {
    final service = LocationService();
    final address = await service.getAddressFromLatLng(latLng);
    if (mounted) {
      setState(() {
        _selectedLocation = latLng;
        _locationAddress = address;
      });
    }
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSectionCard(
                  title: 'How young are you? 🕺',
                  child: _buildAgeSelector(),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'What\'s your vibe?',
                  child: _buildGenderSelector(),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Where are you located?',
                  child: _buildLocationSelector(),
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00BF8F),
                        ),
                      ),
                    )
                    : ConfirmButton(onPressed: _saveProfile, label: 'CONTINUE'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's Get to Know You!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Complete your profile to find your perfect match.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Column(
      children: [
        Text(
          _age != null ? '$_age years old' : 'Select your age',
          style: const TextStyle(
            fontSize: 22,
            color: Color(0xFF00BF8F),
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: (_age ?? 18).toDouble(),
          min: 18,
          max: 100,
          divisions: 82,
          label: _age?.toString() ?? '18',
          activeColor: const Color(0xFF00BF8F),
          inactiveColor: Colors.white.withOpacity(0.2),
          onChanged: (value) {
            setState(() {
              _age = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children:
            _genders.map((gender) {
              final isSelected = _gender == gender;
              return ChoiceChip(
                label: Text(gender),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _gender = gender;
                  });
                },
                labelStyle: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.white.withOpacity(0.1),
                selectedColor: const Color(0xFF00BF8F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color:
                        isSelected
                            ? const Color(0xFF00BF8F)
                            : Colors.white.withOpacity(0.2),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 200,
            color: Colors.black.withOpacity(0.2),
            child:
                _selectedLocation == null
                    ? const Center(
                      child: Text(
                        "Loading map...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : LocationPickerMap(
                      initialLocation: _selectedLocation!,
                      onLocationSelected: (LatLng newLocation) {
                        _updateLocation(newLocation);
                      },
                    ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _locationAddress ?? 'Fetching location...',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _getCurrentLocation,
          icon: const Icon(Icons.my_location, color: Colors.white),
          label: const Text(
            'USE CURRENT LOCATION',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}
