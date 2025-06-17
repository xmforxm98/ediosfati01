import 'package:flutter/material.dart';
import 'package:innerfive/widgets/initial_background.dart';
import 'package:innerfive/screens/onboarding/explanation_screen.dart';
import 'package:innerfive/screens/auth/login_screen.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/screens/analysis/analysis_loading_screen.dart';
import 'package:innerfive/screens/onboarding/onboarding_flow_screen.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:innerfive/widgets/random_login_background.dart';
import 'package:innerfive/screens/legal/terms_of_use_screen.dart';
import 'package:innerfive/screens/legal/privacy_policy_screen.dart';

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
    const Color outlinedButtonBorderColor = Color.fromARGB(
      153,
      255,
      255,
      255,
    ); // For the "already have an account" button

    return Scaffold(
      body: RandomLoginBackground(
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // 로고를 상단에 추가
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Gradient overlay for better text readability
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha((255 * 0.9).round()), // 더 강한 검은색
                      Colors.black
                          .withAlpha((255 * 0.6).round()), // 중간 지점도 더 어둡게
                      Colors.transparent
                    ],
                    stops: const [
                      0.0,
                      0.4, // 더 넓은 범위로 그라데이션 적용
                      0.8,
                    ],
                  ),
                ),
              ),
              // Main Text and Buttons (all bottom-aligned)
              Positioned(
                bottom: 60, // Move content further down
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Main Title
                      const SizedBox(height: 12),

                      // Subtext
                      const SizedBox(height: 36),
                      CustomButton(
                        text: 'Get Started',
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
                                  builder: (context) =>
                                      const TermsOfUseScreen(),
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
      ),
    );
  }
}
