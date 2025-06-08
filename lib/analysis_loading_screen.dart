import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/login_screen.dart';
import 'package:innerfive/screens/new_analysis_report_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _initiateAnalysis();
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
        _loadingMessage = "Analyzing your Eidos...";
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
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_requiresLogin && !_isError)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            const SizedBox(height: 20),
            Text(
              _loadingMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isError ? Colors.redAccent : Colors.white,
                fontSize: 18,
              ),
            ),
            if (_requiresLogin) ...[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _navigateToLogin,
                child: const Text('Continue to Sign In / Sign Up'),
              ),
            ],
            if (_isError && !_requiresLogin)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
          ],
        ),
      ),
    );
  }
}
