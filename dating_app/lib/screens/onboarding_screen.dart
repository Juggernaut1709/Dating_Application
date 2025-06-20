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
    "What is your favorite color?",
    "What is your favorite hobby?",
    "What is your dream job?",
    "What is your favorite food?",
    "What is your favorite movie?",
    "What is your favorite book?",
    "What is your favorite music genre?",
    "What is your favorite travel destination?",
    "What is your favorite sport?",
    "What is your favorite animal?",
    "What is your favorite season?",
    "What is your favorite holiday?",
    "What is your favorite childhood memory?",
    "What is your biggest fear?",
    "What is your biggest achievement?",
    "What is your biggest regret?",
    "What is your biggest dream?",
    "What is your biggest challenge?",
    "What is your biggest inspiration?",
    "What is your biggest goal?",
  ];
  List<double> answers = List.filled(20, -1);

  Future<void> submitAnswers() async {
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == -1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please answer all questions.")));
        return;
      }
    }
    await UserService().saveOnboardingAnswers(answers);
    Navigator.pushNamed(context, '/home_screen');
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (index > 0)
                      ElevatedButton(
                        onPressed: () {
                          PageController controller = PageController(
                            initialPage: index,
                          );
                          controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox(width: 100),
                    if (index < questions.length - 1)
                      ElevatedButton(
                        onPressed:
                            answers[index] == -1
                                ? null
                                : () {
                                  PageController controller = PageController(
                                    initialPage: index,
                                  );
                                  controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                        child: const Text('Next'),
                      )
                    else
                      ElevatedButton(
                        onPressed: answers.contains(-1) ? null : submitAnswers,
                        child: const Text('Submit'),
                      ),
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
