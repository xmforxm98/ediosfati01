import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:innerfive/screens/home/home_dashboard_screen.dart';
import 'package:innerfive/screens/eidos/eidos_group_screen.dart';
import 'package:innerfive/screens/taro/taro_screen.dart';
import 'package:innerfive/screens/profile/my_page_screen.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/screens/report/slide_detailed_report_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/screens/onboarding/onboarding_flow_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  bool _hasAnalysisData = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkAnalysisData();
  }

  Future<void> _checkAnalysisData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final readingsQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('readings')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        setState(() {
          _hasAnalysisData = readingsQuery.docs.isNotEmpty;
          _isLoading = false;
        });
      } catch (e) {
        print("Error checking analysis data: $e");
        setState(() {
          _hasAnalysisData = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _hasAnalysisData = false;
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    // 탭2(Eidos)와 탭3(Tarot)에 대한 접근 제어
    if ((index == 1 || index == 2) && !_hasAnalysisData) {
      _showAnalysisRequiredDialog(index);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAnalysisRequiredDialog(int targetIndex) {
    final String featureName = targetIndex == 1 ? 'Eidos' : 'Tarot';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Analysis Required',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'To access $featureName features, you need to complete your personal analysis first.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingFlowScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Analysis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToReport(NarrativeReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SlideDetailedReportScreen(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF242424), Color(0xFF5E605F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            HomeDashboardScreen(onNavigateToReport: _navigateToReport),
            const EidosGroupScreen(),
            const TaroScreen(),
            const MyPageScreen(),
          ],
        ),
        bottomNavigationBar: _buildFloatingBottomNavBar(),
      ),
    );
  }

  Widget _buildFloatingBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 248,
                height: 64,
                color: Colors.white.withAlpha((255 * 0.4).round()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(0, Icons.home_filled),
                      _buildNavItem(1, Icons.explore_outlined),
                      _buildNavItem(2, Icons.star_outline),
                      _buildNavItem(3, Icons.more_horiz),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    final isLocked = (index == 1 || index == 2) && !_hasAnalysisData;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: isLocked
                  ? Colors.white.withAlpha((255 * 0.4).round())
                  : isSelected
                      ? Colors.white
                      : Colors.white.withAlpha((255 * 0.8).round()),
              size: 24,
            ),
            if (isLocked)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
