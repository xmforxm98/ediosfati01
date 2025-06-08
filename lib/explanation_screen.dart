import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/custom_button.dart';
// import 'name_input_screen.dart';
import 'widgets/animation_extensions.dart';
import 'package:innerfive/onboarding_flow_screen.dart';

class ExplanationScreen extends StatelessWidget {
  const ExplanationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/second_bg.png', // Make sure this file exists
            fit: BoxFit.cover,
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 14),
                  const Text(
                    'The Path to Self-Discovery "Eidos Fati"',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ).animateOnPageLoad(delay: 200.ms),
                  const SizedBox(height: 30),
                  const Text(
                    'Eidos Fati offers a profound analysis of your destiny, combining the principles of Eastern Myeongrihak, Western Birth Line calculations, and the mystical insights of Tarotology. It serves as a spiritual guide, helping you understand your innate nature and the flow of your life.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ).animateOnPageLoad(delay: 400.ms),
                  const Spacer(flex: 3),
                  CustomButton(
                    text: 'Begin My Journey',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingFlowScreen(),
                        ),
                      );
                    },
                    isOutlined: true,
                    textColor: Colors.white,
                    borderColor: Colors.white,
                  ).animateOnPageLoad(delay: 600.ms),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
