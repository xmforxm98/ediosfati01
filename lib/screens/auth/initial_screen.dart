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
    const Color outlinedButtonBorderColor = Color.fromARGB(
      153,
      255,
      255,
      255,
    ); // For the "already have an account" button

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RandomLoginBackground(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Gradient overlay for better text readability - 전체 화면에 적용
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.95), // 매우 강한 검은색
                    Colors.black.withOpacity(0.8), // 강한 검은색
                    Colors.black.withOpacity(0.4), // 중간 어둠
                    Colors.black.withOpacity(0.1), // 약간의 어둠
                    Colors.transparent
                  ],
                  stops: const [
                    0.0,
                    0.2, // 하단부터 빠르게 어두워짐
                    0.4, // 중간 지점
                    0.7, // 위쪽으로 점진적으로 밝아짐
                    1.0,
                  ],
                ),
              ),
            ),
            // SafeArea는 콘텐츠에만 적용
            SafeArea(
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
                                  builder: (context) =>
                                      const ExplanationScreen(),
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
          ],
        ),
      ),
    );
  }
}
