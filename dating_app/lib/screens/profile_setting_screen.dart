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
  int? _age;
  String? _gender;
  LatLng? _selectedLocation;
  String? _locationAddress;

  final List<String> _genders = ['Male', 'Female'];

  Future<void> _saveProfile(int age, String gender, LatLng location) async {
    await UserService().saveProfile(
      age,
      gender,
      location.latitude,
      location.longitude,
    );
    Navigator.pushReplacementNamed(context, '/home_screen');
  }

  Future<void> _getCurrentLocation() async {
    final service = LocationService();
    final location = await service.getCurrentLocation();
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not fetch current location.')),
      );
      return;
    }

    setState(() {
      _selectedLocation = location;
    });

    final address = await service.getAddressFromLatLng(location);
    setState(() {
      _locationAddress = address;
    });
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    final service = LocationService();
    final address = await service.getAddressFromLatLng(latLng);
    setState(() {
      _locationAddress = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Let\'s Get to Know You!')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'How young are you? 🕺',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: (_age ?? 18).toDouble(),
                min: 18,
                max: 100,
                divisions: 82,
                label: _age?.toString() ?? '18',
                onChanged: (value) {
                  setState(() {
                    _age = value.round();
                  });
                },
              ),
              Text(
                _age != null ? '$_age years old' : 'Select your age',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 40),
              Text(
                'What\'s your vibe?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 12,
                children:
                    _genders.map((gender) {
                      return ChoiceChip(
                        label: Text(gender),
                        selected: _gender == gender,
                        onSelected: (selected) {
                          setState(() {
                            _gender = gender;
                          });
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 40),
              Text(
                'Where are you located?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 300,
                child:
                    _selectedLocation == null
                        ? const Center(
                          child: Text("Tap below to pick location"),
                        )
                        : LocationPickerMap(
                          initialLocation: _selectedLocation!,
                          onLocationSelected: (LatLng newLocation) {
                            setState(() {
                              _selectedLocation = newLocation;
                            });
                            _getAddressFromLatLng(newLocation);
                          },
                        ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: Icon(Icons.my_location),
                    label: Text('Use Current Location'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _locationAddress != null
                          ? _locationAddress!
                          : _selectedLocation != null
                          ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                          : 'Tap on map to select location',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              ConfirmButton(
                onPressed: () {
                  if (_age != null &&
                      _gender != null &&
                      _selectedLocation != null) {
                    _saveProfile(_age!, _gender!, _selectedLocation!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please complete all fields')),
                    );
                  }
                },
                text: 'Continue',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
