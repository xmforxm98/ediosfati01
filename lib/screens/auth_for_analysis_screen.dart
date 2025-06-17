import 'package:flutter/material.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'analysis/analysis_loading_screen.dart';
import 'auth/login_screen.dart';
import 'package:innerfive/widgets/random_login_background.dart';

class AuthForAnalysisScreen extends StatefulWidget {
  final UserData userData;
  const AuthForAnalysisScreen({super.key, required this.userData});

  @override
  _AuthForAnalysisScreenState createState() => _AuthForAnalysisScreenState();
}

class _AuthForAnalysisScreenState extends State<AuthForAnalysisScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _handleSignUpAndAnalyze() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Please fill all fields.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Sign up the user and create their profile in one go
      final user = await authService.signUpAndCreateProfile(
        email: _emailController.text,
        password: _passwordController.text,
        userData: widget.userData,
      );

      if (user != null) {
        // 2. Navigate to analysis
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  AnalysisLoadingScreen(userData: widget.userData),
            ),
            (route) => route.isFirst,
          );
        }
      } else {
        throw Exception("Sign up failed. Please try again.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginScreen())).then((
      _,
    ) {
      // After returning from login, check if user is now authenticated
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user != null) {
        // User successfully logged in, proceed to analysis
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                AnalysisLoadingScreen(userData: widget.userData),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: RandomLoginBackground(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Content bottom-aligned
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Create an account to save and view your analysis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 36),
                    CustomButton(
                      text: _isLoading ? 'Processing...' : 'Sign Up & Analyze',
                      onPressed: _isLoading ? () {} : _handleSignUpAndAnalyze,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      isOutlined: false,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Already have an account? Log In',
                      onPressed: _isLoading ? () {} : _navigateToLogin,
                      isOutlined: true,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
