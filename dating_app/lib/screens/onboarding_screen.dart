import 'dart:ui';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/widgets/confirm_button.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/services/user_service.dart';

class OnboardingScreen extends StatefulWidget {
  final String routeName = '/onboarding_screen';
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

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
    "Are you open to long-distance relationships?",
  ];
  late List<double> answers;

  @override
  void initState() {
    super.initState();
    answers = List.filled(questions.length, -1);
  }

  Future<void> submitAnswers() async {
    final unansweredIndex = answers.indexWhere((answer) => answer == -1);
    if (unansweredIndex != -1) {
      ErrorService.showError(
        context,
        'Please answer all questions before submitting.',
      );
      _pageController.animateToPage(
        unansweredIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() => _isLoading = true);
    await UserService().saveOnboardingAnswers(answers);
    final user = await UserService().getCurrentUser();
    if (user != null && await UserService().getUserAge(user.uid) != 0) {
      print("Navigate to Home Screen");
    } else {
      print("Navigate to Profile Settings Screen");
    }
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Color(0xFF8E2DE2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentPage + 1) / questions.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFF00C9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressBar(progress),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: questions.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildQuestionPage(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${_currentPage + 1} of ${questions.length}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFB721FF),
              ),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.4)).clamp(0.0, 1.0);
        }
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuestionCard(index),
            const SizedBox(height: 40),
            if (index == questions.length - 1)
              _isLoading
                  ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF8E2DE2),
                    ),
                  )
                  : ConfirmButton(onPressed: submitAnswers, label: 'FINISH'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.pinkAccent.withOpacity(0.8),
                size: 40,
              ),
              const SizedBox(height: 20),
              Text(
                questions[index],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildAnswerButtons(index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButtons(int index) {
    return ToggleButtons(
      isSelected: [
        answers[index] == 1, // Yes
        answers[index] == 0.5, // Maybe
        answers[index] == 0, // No
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
        if (_currentPage < questions.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      color: Colors.white.withOpacity(0.9),
      selectedColor: Colors.white,
      fillColor: const Color(0xFF8E2DE2),
      splashColor: const Color(0xFF8E2DE2).withOpacity(0.3),
      borderColor: Colors.white.withOpacity(0.3),
      selectedBorderColor: const Color(0xFF8E2DE2),
      borderRadius: BorderRadius.circular(15),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Text('Yes', style: TextStyle(fontSize: 16)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Text('Maybe', style: TextStyle(fontSize: 16)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Text('No', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
