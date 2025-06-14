import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:innerfive/services/image_service.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/login_screen.dart';
import 'package:innerfive/screens/new_analysis_report_screen.dart';
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
  String? _backgroundUrl;

  @override
  void initState() {
    super.initState();
    _loadBackground();
    _initiateAnalysis();
  }

  Future<void> _loadBackground() async {
    final url = await ImageService.getLoadingBackgroundUrl();
    if (mounted) {
      setState(() {
        _backgroundUrl = url;
      });
    }
  }

  dynamic _sanitizeForFirestore(dynamic data) {
    if (data is Map) {
      final sanitizedMap = <String, dynamic>{};
      data.forEach((key, value) {
        sanitizedMap[key] = _sanitizeForFirestore(value);
      });
      return sanitizedMap;
    }
    if (data is List) {
      return data
          .map((item) => _sanitizeForFirestore(item))
          .where((item) => item != null)
          .toList();
    }
    if (data == null) {
      return <String, dynamic>{};
    }
    return data;
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
      final reportJson = await _apiService.getAnalysisReport(
        widget.userData.toJson(),
      );
      final reportData = jsonDecode(reportJson);

      final sanitizedReportData = _sanitizeForFirestore(reportData);

      final narrativeReport = NarrativeReport.fromJson(reportData);

      await _authService.saveUserData(userId, {
        'userInput': widget.userData.toJson(),
        'report': sanitizedReportData,
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => NewAnalysisReportScreen(report: narrativeReport),
          ),
        );
      }
    } catch (e) {
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
      body: GradientBlurredBackground(
        imageUrl: _backgroundUrl,
        isLoading: _backgroundUrl == null,
        blurStrength: 8.0,
        overlayOpacity: 0.6,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Loading animation and message
              if (!_requiresLogin && !_isError) ...[
                // Animated title with dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _loadingMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildLoadingDots(),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 60),

                // Description text with blur background
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Beyond simple data processing, this is the time to weave your innate potential, life\'s pivotal moments, and psychological tendencies into one unified wisdom.\n\nWe are decoding the message that the universe has bestowed upon you.\n\nSoon, an analysis filled with profound insights into your life will unfold.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
              ],

              // Error message
              if (_isError && !_requiresLogin) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _loadingMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],

              // Login required
              if (_requiresLogin) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _loadingMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue to Sign In / Sign Up'),
                ),
              ],

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(
              delay: Duration(milliseconds: 200 * index),
              duration: const Duration(milliseconds: 600),
            )
            .then()
            .fadeOut(
              delay: Duration(milliseconds: 200 * (2 - index)),
              duration: const Duration(milliseconds: 600),
            );
      }),
    );
  }
}
