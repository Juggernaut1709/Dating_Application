import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';

class OnboardingScreen extends StatelessWidget {
  final String routeName = '/onboarding_screen';
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int? selectedAge;
    String? selectedGender;
    final List<String> genders = ['Male', 'Female', 'Other'];

    Future<void> completeUserProfile(int age, String gender) async {
      final UserService userService = UserService();
      await userService.completeUserProfile(context, age: age, gender: gender);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Age:', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 16),
                        DropdownButton<int>(
                          value: selectedAge,
                          hint: const Text('Select Age'),
                          items: List.generate(
                            83,
                            (index) => DropdownMenuItem(
                              value: index + 18,
                              child: Text('${index + 18}'),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedAge = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Gender:', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 16),
                        ToggleButtons(
                          borderRadius: BorderRadius.circular(12),
                          isSelected:
                              genders.map((g) => g == selectedGender).toList(),
                          onPressed: (index) {
                            setState(() {
                              selectedGender = genders[index];
                            });
                          },
                          children:
                              genders
                                  .map(
                                    (g) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(g),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          (selectedAge != null && selectedGender != null)
                              ? () async {
                                await completeUserProfile(
                                  selectedAge!,
                                  selectedGender!,
                                );
                              }
                              : null,
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
