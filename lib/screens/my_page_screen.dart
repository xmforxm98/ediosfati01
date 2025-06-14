import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:innerfive/onboarding_flow_screen.dart';
import 'package:innerfive/screens/privacy_settings_screen.dart';
import 'package:innerfive/screens/support_screen.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/services/notification_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  User? _user;
  Map<String, dynamic>? _userData;
  String? _eidosTitle;
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  String? _userName;
  String? _userBirthDate;
  String? _userBirthTime;
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _notificationService.addListener(_onNotificationSettingsChanged);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationSettingsChanged);
    super.dispose();
  }

  void _onNotificationSettingsChanged() {
    setState(() {});
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .get();
      if (doc.exists) {
        _userData = doc.data();
      }

      // Fetch latest report for eidos title
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
        if (latestReadingData.containsKey('report')) {
          final report = NarrativeReport.fromJson(
            latestReadingData['report'] as Map<String, dynamic>,
          );
          _eidosTitle = report.eidosSummary.title;
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts.first.isNotEmpty ? parts.first[0] : '') +
          (parts.last.isNotEmpty ? parts.last[0] : '');
    }
    return parts.first.isNotEmpty ? parts.first[0] : '';
  }

  String _getMemberSince(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return 'Member since ${DateFormat('MMMM yyyy').format(timestamp.toDate())}';
  }

  String _formatBirthDate(dynamic birthDate) {
    if (birthDate == null || birthDate == '' || birthDate == 'null') {
      return 'Not Set';
    }
    return birthDate.toString();
  }

  String _formatBirthTime(dynamic birthTime) {
    if (birthTime == null ||
        birthTime == '' ||
        birthTime == 'null' ||
        birthTime == 'null:null') {
      return 'Not Set';
    }
    return birthTime.toString();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (_user == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildSettingsSection(),
              const SizedBox(height: 32),
              _buildLogoutButton(authService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[800],
                child: Text(
                  _getInitials(_userData?['nickname'] ?? _user?.displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData?['nickname'] ??
                          _userData?['displayName'] ??
                          _user?.displayName ??
                          'No Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _eidosTitle ?? 'The Essence of Your Eidos',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => const OnboardingFlowScreen(),
                        ),
                      )
                      .then((_) => _loadUserData());
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Birth Date',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatBirthDate(_userData?['birthDate']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Birth Time',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatBirthTime(_userData?['birthTime']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildSectionContainer(
      title: 'Settings',
      children: [
        _buildNotificationTile(),
        _buildListTile(
          'Privacy Settings',
          'Manage data sharing preferences',
          Icons.shield_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PrivacySettingsScreen(),
              ),
            );
          },
        ),
        _buildListTile(
          'Support',
          'Get help and contact us',
          Icons.help_outline,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SupportScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon, {
    bool showBadge = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge)
            const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildNotificationTile() {
    return ExpansionTile(
      leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
      title: const Text(
        'Notifications',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      children: [
        ListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive all notifications'),
          trailing: Switch(
            value: _notificationService.notificationsEnabled,
            onChanged: (value) {
              _notificationService.setNotificationsEnabled(value);
            },
          ),
        ),
        if (_notificationService.notificationsEnabled) ...[
          ListTile(
            title: const Text('Daily Briefing'),
            subtitle: const Text('Daily insights at 9:00 AM'),
            trailing: Switch(
              value: _notificationService.dailyBriefingEnabled,
              onChanged: (value) {
                _notificationService.setDailyBriefingEnabled(value);
              },
            ),
          ),
          ListTile(
            title: const Text('Analysis Reminders'),
            subtitle: const Text('Reminders to complete analysis'),
            trailing: Switch(
              value: _notificationService.analysisRemindersEnabled,
              onChanged: (value) {
                _notificationService.setAnalysisRemindersEnabled(value);
              },
            ),
          ),
          ListTile(
            title: const Text('Insight Updates'),
            subtitle: const Text('New insights and updates'),
            trailing: Switch(
              value: _notificationService.insightUpdatesEnabled,
              onChanged: (value) {
                _notificationService.setInsightUpdatesEnabled(value);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoutButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await authService.signOut();
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey[900],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
