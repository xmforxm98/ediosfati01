import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/screens/new_analysis_report_screen.dart'; // Re-use the UI components

class MyReportScreen extends StatefulWidget {
  const MyReportScreen({super.key});

  @override
  State<MyReportScreen> createState() => _MyReportScreenState();
}

class _MyReportScreenState extends State<MyReportScreen> {
  Future<Map<String, dynamic>?>? _reportFuture;

  @override
  void initState() {
    super.initState();
    _fetchLatestReport();
  }

  void _fetchLatestReport() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _reportFuture = _getReportFromFirestore(user.uid);
      });
    }
  }

  Future<Map<String, dynamic>?> _getReportFromFirestore(String userId) async {
    try {
      print("Fetching report for user: $userId");
      final readingsQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('readings')
              // Assuming there's a timestamp to get the latest.
              // If not, you might need to adjust this query.
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      print("Found ${readingsQuery.docs.length} readings");

      if (readingsQuery.docs.isNotEmpty) {
        final latestReadingData = readingsQuery.docs.first.data();
        print("Latest reading data keys: ${latestReadingData.keys.toList()}");
        if (latestReadingData.containsKey('report')) {
          print("Report found, returning full data");
          return latestReadingData; // 전체 데이터 반환
        } else {
          print("No 'report' key found in reading data");
        }
      } else {
        print("No readings found for user");
      }
    } catch (e, stackTrace) {
      print("Error fetching report: $e");
      print("Stack trace: $stackTrace");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Report', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchLatestReport,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading report: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchLatestReport,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final reportData = snapshot.data;
          if (reportData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No analysis report found.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchLatestReport,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          // Create NarrativeReport from the report data
          final report = NarrativeReport.fromJson(
            reportData['report'] as Map<String, dynamic>,
          );

          // Pass both report and analysisData (the original report data)
          return NewAnalysisReportScreen(
            report: report,
            analysisData: reportData['report'] as Map<String, dynamic>,
          );
        },
      ),
    );
  }
}
