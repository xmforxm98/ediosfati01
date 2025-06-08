import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (data == null) {
      return null;
    }

    // Convert everything to JSON string first, then parse back to ensure no nested arrays
    try {
      String jsonString = jsonEncode(data);
      Map<String, dynamic> parsedData = jsonDecode(jsonString);

      // Now recursively convert any remaining lists to maps
      return _convertListsToMaps(parsedData);
    } catch (e) {
      // If JSON encoding fails, convert to string
      return data.toString();
    }
  }

  dynamic _convertListsToMaps(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      Map<String, dynamic> result = {};
      data.forEach((key, value) {
        result[key.toString()] = _convertListsToMaps(value);
      });
      return result;
    }

    if (data is List) {
      // Convert list to map with index as key
      Map<String, dynamic> result = {};
      for (int i = 0; i < data.length; i++) {
        result[i.toString()] = _convertListsToMaps(data[i]);
      }
      return result;
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
      print("Starting analysis for user: $userId");

      final reportJson = await _apiService.getAnalysisReport(
        widget.userData.toJson(),
      );
      print("Received report JSON: ${reportJson.length} characters");

      final reportData = jsonDecode(reportJson);
      print("Parsed report data keys: ${reportData.keys.toList()}");

      final sanitizedReportData = _sanitizeForFirestore(reportData);
      print("Sanitized report data");

      final narrativeReport = NarrativeReport.fromJson(reportData);
      print("Created NarrativeReport successfully");

      print("Saving report to Firestore...");
      await _authService.saveUserData(userId, {
        'userInput': widget.userData.toJson(),
        'report': sanitizedReportData,
      });
      print("Report saved to Firestore successfully");

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => NewAnalysisReportScreen(report: narrativeReport),
          ),
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
