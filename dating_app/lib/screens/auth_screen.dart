import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dating_app/services/error_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/widgets/circular_loader.dart';
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E2DE2), // vivid purple
              Color(0xFF4A00E0), // deep purple
              Color(0xFF2575fc), // light blue
            ],
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 70,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "VibeMatch",
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const Text(
          "Find your perfect match in harmony",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAnimatedForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: isLogin ? _buildLoginUI() : _buildSignUpUI(),
    );
  }

  Widget _buildFormContainer({Key? key, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          key: key,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
          _buildGradientButton("LOGIN", signIn),
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
          _buildGradientButton("SIGN UP", signUp),
          const SizedBox(height: 16),
          _buildToggleText("Already have an account?", " Login"),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleText(String text1, String text2) {
    return GestureDetector(
      onTap: toggleScreen,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
          children: [
            TextSpan(text: text1),
            TextSpan(
              text: text2,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
