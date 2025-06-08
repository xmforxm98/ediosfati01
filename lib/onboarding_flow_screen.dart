import 'package:flutter/material.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:innerfive/screens/auth_for_analysis_screen.dart';

// Import step widgets which we will create next
import 'onboarding_steps/name_step.dart';
import 'onboarding_steps/birth_date_step.dart';
import 'onboarding_steps/birth_time_step.dart';
import 'onboarding_steps/gender_step.dart';
import 'onboarding_steps/city_step.dart';
import 'analysis_loading_screen.dart';
import 'models/user_data.dart';
// import 'package:innerfive/gender_selection_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  _OnboardingFlowScreenState createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  final UserData _userData = UserData();
  double _progress = 0.2;

  void _nextPage() {
    if (_pageController.page! < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page, call the API
      _callApiAndNavigate();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _callApiAndNavigate() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    // If the user is already logged in
    if (user != null) {
      // Update their profile with the latest info from onboarding
      await authService.updateUserProfile(user.uid, _userData);
      // Proceed to analysis
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AnalysisLoadingScreen(userData: _userData),
          ),
        );
      }
    } else {
      // If user is NOT logged in, navigate to the special auth screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AuthForAnalysisScreen(userData: _userData),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        // 5 steps, so progress is (page + 1) / 5
        _progress = (_pageController.page! + 1) / 5.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> onboardingSteps = [
      NameStep(userData: _userData, onContinue: _nextPage),
      BirthDateStep(userData: _userData, onNextStep: _nextPage),
      BirthTimeStep(userData: _userData, onComplete: _nextPage),
      GenderStep(userData: _userData, onNext: _nextPage),
      CityStep(userData: _userData, onContinue: _nextPage),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            _pageController.hasClients && _pageController.page != 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _previousPage,
                )
                : null,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/input_bg.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: LinearPercentIndicator(
                    percent: _progress,
                    lineHeight: 8,
                    backgroundColor: Colors.white24,
                    progressColor: Colors.white,
                    barRadius: const Radius.circular(10),
                    animation: true,
                    animateFromLastPercent: true,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: onboardingSteps,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
