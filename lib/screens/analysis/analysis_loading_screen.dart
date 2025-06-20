import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:innerfive/services/image_service.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/screens/auth/login_screen.dart';
import 'package:innerfive/screens/main_screen.dart';
import 'package:innerfive/widgets/gradient_blurred_background.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  final UserData userData;

  const AnalysisLoadingScreen({super.key, required this.userData});

  @override
  _AnalysisLoadingScreenState createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  String _loadingMessage = "Checking authentication...";
  bool _isError = false;
  bool _requiresLogin = false;
  final bool _analysisComplete = false;
  String? _backgroundUrl;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _loadBackground();
    _initiateAnalysis();
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBackground() async {
    final url = await ImageService.getSecondBackgroundUrl();
    if (mounted) {
      setState(() {
        _backgroundUrl = url;
      });
    }
  }

  Future<void> _initiateAnalysis() async {
    final user = _authService.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loadingMessage =
              "To save your analysis,\nplease sign in or sign up.";
          _requiresLogin = true;
        });
      }
    } else {
      await _startAnalysis(user.uid);
    }
  }

  void _navigateToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()))
        .then((_) {
      _initiateAnalysis();
    });
  }

  Future<void> _startAnalysis(String userId) async {
    if (mounted) {
      setState(() {
        _loadingMessage = "Analyzing your Eidos";
        _isError = false;
        _requiresLogin = false;
      });
    }

    try {
      print("🔄 Starting analysis for user: $userId");
      print("🔄 User data being sent: ${widget.userData.toJson()}");

      final year = int.tryParse(widget.userData.year ?? '');
      final month = int.tryParse(widget.userData.month ?? '');
      final day = int.tryParse(widget.userData.day ?? '');

      if (year == null || month == null || day == null) {
        throw Exception(
            'Invalid birth date. Please go back and re-enter your birth information.');
      }

      final userName =
          '${widget.userData.firstName ?? ''} ${widget.userData.lastName ?? ''}'
              .trim();

      final requestData = {
        'name': userName.isNotEmpty ? userName : widget.userData.nickname,
        'year': year,
        'month': month,
        'day': day,
        'gender': widget.userData.gender == Gender.male ? 'male' : 'female',
        'birth_city': widget.userData.city,
        'hour': int.tryParse(widget.userData.hour ?? '12') ?? 12,
      };

      final reportData = await _apiService.getAnalysisReport(requestData);
      print("✅ Received report data. Keys: ${reportData.keys.toList()}");

      // Check for eidos_type in the response
      if (reportData.containsKey('eidos_type')) {
        print("✅ Response contains eidos_type: ${reportData['eidos_type']}");
      } else {
        print("❌ Response does NOT contain eidos_type");
      }

      // Check eidos_summary
      if (reportData.containsKey('eidos_summary')) {
        final eidosSummary =
            reportData['eidos_summary'] as Map<String, dynamic>;
        print(
            "✅ Response contains eidos_summary: ${eidosSummary.keys.toList()}");
        print("✅ Eidos summary eidos_type: ${eidosSummary['eidos_type']}");
      } else {
        print("❌ Response does NOT contain eidos_summary");
      }

      print("🔄 Full API response: $reportData");

      print("Saving report to Firestore...");
      await _authService.saveUserData(userId, {
        'userInput': widget.userData.toJson(),
        'report': reportData,
      });
      print("Report saved to Firestore successfully");

      // Navigate to the main screen, specifically to the Eidos tab (index 1)
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialIndex: 1),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e, stackTrace) {
      print("Analysis error: $e");
      print("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _loadingMessage = "Analysis Failed:\n\n$e";
          _isError = true;
        });
      }
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

                  // 분석 상태에 따른 타이틀
                  Text(
                    _analysisComplete
                        ? 'Analysis Complete!'
                        : 'Analyzing Your Eidos',
                    style: const TextStyle(
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

                  // 메시지 내용
                  Text(
                    _getAnalysisMessage(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),

                  const Spacer(flex: 3),

                  // 에러나 로그인 필요 시 버튼 표시
                  if (_isError || _requiresLogin)
                    _buildActionButton()
                        .animate(delay: 600.ms)
                        .fadeIn(duration: 500.ms),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAnalysisMessage() {
    if (_analysisComplete) {
      return 'Your Eidos analysis has been completed successfully!\n\nWe have decoded the unique patterns of your destiny and created a comprehensive report that reveals your innate potential and life\'s flow.\n\nYou will be redirected to your personalized report shortly.';
    } else if (_isError) {
      return 'We encountered an issue while analyzing your data.\n\n$_loadingMessage\n\nPlease try again or contact support if the problem persists.';
    } else if (_requiresLogin) {
      return 'To save your analysis and access your personalized Eidos report, please sign in or create an account.\n\nYour cosmic insights await you on the other side.';
    } else {
      return 'Beyond simple data processing, this is the time to weave your innate potential, life\'s pivotal moments, and psychological tendencies into one unified wisdom.\n\nWe are decoding the message that the universe has bestowed upon you.\n\nSoon, an analysis filled with profound insights into your life will unfold.';
    }
  }

  Widget _buildActionButton() {
    if (_requiresLogin) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _navigateToLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Continue to Sign In / Sign Up'),
        ),
      );
    } else if (_isError) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Go Back'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
