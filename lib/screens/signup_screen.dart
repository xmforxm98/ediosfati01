import 'package:flutter/material.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:innerfive/widgets/random_login_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;

  void _handleSignUp() {
    setState(() {
      _isLoading = true;
    });
    // TODO: Implement sign up logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RandomLoginBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24.0),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                        text: '회원가입',
                        onPressed: _handleSignUp,
                        backgroundColor: const Color(0xFF0f3460),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
