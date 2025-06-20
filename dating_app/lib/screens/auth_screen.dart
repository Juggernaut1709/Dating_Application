import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/widgets/confirm_button.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/services/auth_service.dart';
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

  String? _errorMessage;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  void toggleScreen() {
    setState(() {
      isLogin = !isLogin;
      _errorMessage = null;
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      isLoading = false;
    });
  }

  void signIn() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    final responseMessage = await _authService.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (responseMessage == "Success") {
      _userService.handleLandingNavigation(context);
    } else {
      setState(() {
        _errorMessage = responseMessage;
        showError();
      });
    }
  }

  void signUp() async {
    final validationMessage = validatePassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (validationMessage.isNotEmpty) {
      setState(() {
        _errorMessage = validationMessage;
        showError();
      });
      return;
    }
    final responseMessage = await _authService.signup(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );
    setState(() {
      _errorMessage = responseMessage;
      showError();
    });
  }

  String validatePassword(String password, String confirmPassword) {
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
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder:
                (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
            child: isLogin ? _buildLoginScreen() : _buildSignUpScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginScreen() {
    return Center(
      key: const ValueKey(1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputField(controller: _emailController, hintText: "Email"),
            const SizedBox(height: 16),
            InputField(
              controller: _passwordController,
              hintText: "Password",
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ConfirmButton(onPressed: signIn),
            const SizedBox(height: 10),
            TextButton(
              onPressed: toggleScreen,
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpScreen() {
    return Center(
      key: const ValueKey(2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputField(controller: _usernameController, hintText: "Name"),
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
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ConfirmButton(onPressed: signUp),
            const SizedBox(height: 10),
            TextButton(
              onPressed: toggleScreen,
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }

  Widget showError() {
    return _errorMessage == null
        ? const SizedBox.shrink()
        : Text(_errorMessage!, style: TextStyle(color: Colors.red));
  }
}
