import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'explanation_screen.dart';
import 'login_screen.dart';
import 'widgets/custom_button.dart'; // Import the custom button
import 'terms_of_use_screen.dart';
import 'privacy_policy_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth_service.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    // All user checking logic is now handled by AuthWrapper in main.dart.
    // This screen is only shown if the user is not logged in.
  }

  @override
  Widget build(BuildContext context) {
    // Define a primary color, e.g., from the theme or a specific color
    // For now, let's use a light grey for the main button background for better contrast with black text
    // and a transparent background for the outlined button (achieved by isOutlined=true).
    final Color primaryButtonColor = Colors.grey[300]!;
    final Color outlinedButtonBorderColor = const Color.fromARGB(
      153,
      255,
      255,
      255,
    ); // For the "already have an account" button

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background Image
          Image.asset(
            'assets/images/login_bg.png', // Changed background image
            fit: BoxFit.cover,
          ),
          // Main Text and Buttons (all bottom-aligned)
          Positioned(
            bottom: 60, // Move content further down
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Main Title
                  const SizedBox(height: 12),

                  // Subtext
                  const SizedBox(height: 36),
                  CustomButton(
                    text: 'Start',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExplanationScreen(),
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    isOutlined: false,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'I already have an account',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    isOutlined: true,
                    textColor: Colors.white,
                    borderColor: outlinedButtonBorderColor,
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
                              builder: (context) => const PrivacyPolicyScreen(),
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
    );
  }
}
