import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/widgets/confirm_button.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final String routeName = '/onboarding_screen';

  final List<String> questions = [
    "Do you consider yourself an introvert?",
    "Do you enjoy trying new things?",
    "Do you believe in love at first sight?",
    "Is humor important to you in a partner?",
    "Do you consider yourself emotionally expressive?",
    "Do you prefer deep conversations over small talk?",
    "Is physical appearance more important than personality?",
    "Are you more of a morning person?",
    "Do you want to get married someday?",
    "Do you believe partners should always share everything?",
    "Would you date someone with very different religious views?",
    "Is a healthy lifestyle important to you?",
    "Do you enjoy traveling?",
    "Is spending time with family important to you?",
    "Do you consider career a top priority right now?",
    "Do you believe in soulmates?",
    "Are you interested in pets or animals?",
    "Do you work out regularly?",
    "Would you date someone who doesn’t want children?",
    "Do you work out regularly?",
  ];
  List<double> answers = List.filled(20, -1);

  Future<void> submitAnswers() async {
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == -1) {
        ErrorService.showError(
          context,
          'Please answer all questions before submitting.',
        );
        return;
      }
    }
    await UserService().saveOnboardingAnswers(answers);
    Navigator.pushReplacementNamed(context, '/profile_setting_screen');
  }

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: PageView.builder(
        itemCount: questions.length,
        controller: PageController(initialPage: currentPage),
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Question ${index + 1} of ${questions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  questions[index],
                  style: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ToggleButtons(
                  isSelected: [
                    answers[index] == 1,
                    answers[index] == 0.5,
                    answers[index] == 0,
                  ],
                  onPressed: (selectedIndex) {
                    setState(() {
                      if (selectedIndex == 0) {
                        answers[index] = 1;
                      } else if (selectedIndex == 1) {
                        answers[index] = 0.5;
                      } else {
                        answers[index] = 0;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text('Yes'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text('Maybe'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text('No'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (index == 19)
                      ConfirmButton(onPressed: submitAnswers, text: 'Submit'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
