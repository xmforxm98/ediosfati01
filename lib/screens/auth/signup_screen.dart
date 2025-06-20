import 'package:flutter/material.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:innerfive/widgets/random_login_background.dart';
import 'package:innerfive/screens/legal/privacy_policy_screen.dart';
import 'package:innerfive/screens/legal/terms_of_use_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
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
                      ' ',
                      style: TextStyle(
                        fontSize: 28,
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
                      ),
                      obscureText: true,
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
                      ),
                      obscureText: true,
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
                      text: 'Sign Up',
                      onPressed: () async {
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          setState(() {
                            _errorMessage = "Passwords do not match.";
                          });
                          return;
                        }

                        final result =
                            await authService.signUpWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text,
                        );

                        if (result['success']) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        } else {
                          setState(() {
                            _errorMessage = result['message'];
                          });
                        }
                      },
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      isOutlined: false,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Already have an account? Sign In',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      isOutlined: true,
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TermsOfUseScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Terms of Use',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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
