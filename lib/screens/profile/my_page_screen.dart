import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/widgets/profile/profile_header.dart';
import 'package:innerfive/widgets/profile/settings_section.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? _user;
  Map<String, dynamic>? _userData;
  String? _eidosTitle;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (doc.exists) {
        _userData = doc.data();
      }

      try {
        final readingsQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('readings')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (readingsQuery.docs.isNotEmpty) {
          final latestReadingData = readingsQuery.docs.first.data();
          if (latestReadingData.containsKey('report')) {
            final reportData = latestReadingData['report'];
            if (reportData is Map<String, dynamic>) {
              final report = NarrativeReport.fromJson(reportData);
              // 여러 필드에서 유효한 타이틀 찾기
              _eidosTitle = report.eidosSummary.title;
              if (_eidosTitle == null ||
                  _eidosTitle == 'N/A' ||
                  _eidosTitle!.isEmpty) {
                _eidosTitle = report.eidosSummary.summaryTitle;
              }
              if (_eidosTitle == null ||
                  _eidosTitle == 'N/A' ||
                  _eidosTitle!.isEmpty) {
                _eidosTitle = report.eidosType;
              }
              if (_eidosTitle == null ||
                  _eidosTitle == 'N/A' ||
                  _eidosTitle!.isEmpty) {
                _eidosTitle = 'The Essence of Your Eidos';
              }
              print('📱 My Page - Eidos title: $_eidosTitle');
            }
          }
        }
      } catch (e) {
        print("Error loading latest report: $e");
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text(
              'My Page',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            pinned: false,
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ProfileHeader(
                    userData: _userData,
                    eidosTitle: _eidosTitle,
                    onUpdate: _loadUserData,
                  ),
                  const SizedBox(height: 32),
                  const SettingsSection(),
                  const SizedBox(height: 180),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
