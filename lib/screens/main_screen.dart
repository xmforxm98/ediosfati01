import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:innerfive/screens/home_dashboard_screen.dart';
import 'package:innerfive/screens/my_report_screen.dart';
import 'package:innerfive/screens/taro_screen.dart';
import 'package:innerfive/screens/my_page_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _widgetOptions = <Widget>[
      HomeDashboardScreen(onNavigateToReport: () => _onItemTapped(1)),
      const MyReportScreen(),
      const TaroScreen(),
      const MyPageScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
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
                color: Colors.white.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(0, Icons.home_filled),
                      _buildNavItem(1, Icons.article_outlined),
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
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          size: 24,
        ),
      ),
    );
  }
}
