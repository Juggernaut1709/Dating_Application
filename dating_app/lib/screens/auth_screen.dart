import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/widgets/circular_loader.dart';
import 'package:dating_app/widgets/confirm_button.dart';
import 'package:dating_app/widgets/input_field.dart';

class AuthScreen extends StatefulWidget {
  final String routeName = '/auth_screen';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  void toggleScreen() {
    setState(() {
      isLogin = !isLogin;
      _clearControllers();
    });
  }

  void _clearControllers() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  void _handleAuthAction(Future<String> Function() authFunction) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final responseMessage = await authFunction();

    setState(() => isLoading = false);

    if (!mounted) return;

    if (responseMessage == "Success") {
      _userService.handleLandingNavigation(context);
    } else {
      ErrorService.showError(context, responseMessage);
    }
  }

  void signIn() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ErrorService.showError(context, "Email and Password cannot be empty");
      return;
    }
    _handleAuthAction(
      () => _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      ),
    );
  }

  void signUp() {
    final validationMessage = _validatePassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (validationMessage.isNotEmpty) {
      ErrorService.showError(context, validationMessage);
      return;
    }
    _handleAuthAction(
      () => _authService.signup(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      ),
    );
  }

  String _validatePassword(String password, String confirmPassword) {
    if (password.length < 6) {
      return "Password must be at least 6 characters long";
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(password)) {
      return "Password must contain both letters and numbers";
    }
    if (password != confirmPassword) {
      return "Passwords do not match";
    }
    return "";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        // A beautiful gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child:
                isLoading
                    ? const CircularLoader(size: 50)
                    : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildAnimatedForm(),
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(Icons.music_note, color: Color(0xFF00BF8F), size: 50),
        SizedBox(height: 10),
        Text(
          "VibeMatch",
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          "Find your rhythm.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAnimatedForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final bool isGoingToLogin = isLogin;

        final Offset slideInBeginOffset =
            isGoingToLogin ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
        final Offset slideOutEndOffset =
            isGoingToLogin ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

        final tween = Tween<Offset>(
          begin:
              animation.status == AnimationStatus.reverse
                  ? Offset.zero
                  : slideInBeginOffset,
          end:
              animation.status == AnimationStatus.reverse
                  ? slideOutEndOffset
                  : Offset.zero,
        );

        final offsetAnimation = tween.animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isLogin ? _buildLoginUI() : _buildSignUpUI(),
    );
  }

  Widget _buildFormContainer({Key? key, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          key: key,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLoginUI() {
    return _buildFormContainer(
      key: const ValueKey('login'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputField(controller: _emailController, hintText: "Email"),
          const SizedBox(height: 16),
          InputField(
            controller: _passwordController,
            hintText: "Password",
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ConfirmButton(onPressed: signIn, label: "LOGIN"),
          const SizedBox(height: 16),
          _buildToggleText("Don't have an account?", " Sign Up"),
        ],
      ),
    );
  }

  Widget _buildSignUpUI() {
    return _buildFormContainer(
      key: const ValueKey('signup'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputField(controller: _usernameController, hintText: "Username"),
          const SizedBox(height: 16),
          InputField(controller: _emailController, hintText: "Email"),
          const SizedBox(height: 16),
          InputField(
            controller: _passwordController,
            hintText: "Password",
            obscureText: true,
          ),
          const SizedBox(height: 16),
          InputField(
            controller: _confirmPasswordController,
            hintText: "Confirm Password",
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ConfirmButton(onPressed: signUp, label: "SIGN UP"),
          const SizedBox(height: 16),
          _buildToggleText("Already have an account?", " Login"),
        ],
      ),
    );
  }

  Widget _buildToggleText(String text1, String text2) {
    return GestureDetector(
      onTap: toggleScreen,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
          children: [
            TextSpan(text: text1),
            TextSpan(
              text: text2,
              style: const TextStyle(
                color: Color(0xFF00BF8F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
