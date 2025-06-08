import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/analysis_report.dart';

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToReport;

  const HomeDashboardScreen({super.key, required this.onNavigateToReport});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  User? _user;
  String _userName = 'User';
  Map<String, dynamic>? _latestUserInput;
  NarrativeReport? _latestReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      setState(() {
        _userName = _user?.displayName ?? 'User';
      });

      // Fetch latest report from Firestore
      try {
        final readingsQuery =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_user!.uid)
                .collection('readings')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .get();

        if (readingsQuery.docs.isNotEmpty) {
          final latestReadingData = readingsQuery.docs.first.data();
          if (latestReadingData.containsKey('report') &&
              latestReadingData.containsKey('userInput')) {
            setState(() {
              _latestUserInput =
                  latestReadingData['userInput'] as Map<String, dynamic>?;
              _latestReport = NarrativeReport.fromJson(
                latestReadingData['report'] as Map<String, dynamic>,
              );
            });
          }
        }
      } catch (e) {
        print("Error loading latest report: $e");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Today's Eidos Briefing",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      _buildQuickAccessMenu(),
                      if (_latestReport != null) ...[
                        const SizedBox(height: 24),
                        _buildLatestAnalysisCard(),
                      ],
                      const SizedBox(height: 24),
                      _buildCuratedContentFeed(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSummaryCard() {
    String todayMessage =
        _latestReport != null
            ? "$_userName, ${_latestReport!.eidosSummary.currentEnergyText}"
            : "$_userName, the energy of 'Creation' is with you today.";

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todayMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Chip(
                  label: Text('#Challenge'),
                  backgroundColor: Colors.white24,
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('#NewConnections'),
                  backgroundColor: Colors.white24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _latestReport?.ryusWisdom.message ??
                  "A small idea could lead to a big outcome. Try to jot down your thoughts.",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestAnalysisCard() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Latest Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_latestUserInput != null) ...[
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${_latestUserInput!['firstName'] ?? ''} ${_latestUserInput!['lastName'] ?? ''}'
                        .trim(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_latestUserInput!['year']}-${_latestUserInput!['month']}-${_latestUserInput!['day']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (_latestUserInput!['city'] != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _latestUserInput!['city'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
            ],
            Text(
              _latestReport?.eidosSummary.summaryText ??
                  'Your analysis is ready to view.',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onNavigateToReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Full Analysis'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessMenu() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onNavigateToReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('My Innate Eidos'),
      ),
    );
  }

  Widget _buildCuratedContentFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'For You',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const ListTile(
            title: Text(
              'Habits to Avoid for a Water-element Person',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text('Article', style: TextStyle(color: Colors.white70)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ),
        ),
        Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const ListTile(
            title: Text(
              '3 Tips to Seize Opportunities in 2025',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text('Article', style: TextStyle(color: Colors.white70)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
