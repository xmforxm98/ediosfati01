import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:innerfive/widgets/gradient_blurred_background.dart';
import 'package:innerfive/services/image_service.dart';
import 'widgets/custom_button.dart';
import 'package:innerfive/onboarding_flow_screen.dart';

class ExplanationScreen extends StatefulWidget {
  const ExplanationScreen({super.key});

  @override
  State<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends State<ExplanationScreen> {
  String? _backgroundUrl;

  @override
  void initState() {
    super.initState();
    _loadBackground();
  }

  Future<void> _loadBackground() async {
    final url = await ImageService.getSecondBackgroundUrl();
    if (mounted) {
      setState(() {
        _backgroundUrl = url;
      });
    }
  }

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
      body: GradientBlurredBackground(
        imageUrl: _backgroundUrl,
        isLoading: _backgroundUrl == null,
        overlayOpacity: 0.3,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: SafeArea(
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
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome. I\'m Ryu, the founder of Eidos Destiny Studies.\n\nIn 1986, I integrated the essence of Eastern Myeongrihak (Four Pillars of Destiny), Western Birth Chart Analysis, and Tarot to create \'Eidos Destiny Studies\'.\n\nHere, you\'ll discover the light of your innate \'Eidos\' (Essence) and gain a deep understanding of life\'s \'Fati\' (Destiny) flow.\n\nGo beyond passive predictions and acquire the true wisdom to wisely guide your life.\n\nBegin your journey now.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
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
                  ).animate(delay: 600.ms).fadeIn(duration: 500.ms),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
