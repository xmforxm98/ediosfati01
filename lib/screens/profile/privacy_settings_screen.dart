import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _analyticsEnabled = true;
  bool _marketingEnabled = false;
  bool _dataMinimizationEnabled = true;
  bool _crashReportingEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  void _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _marketingEnabled = prefs.getBool('marketing_enabled') ?? false;
      _dataMinimizationEnabled =
          prefs.getBool('data_minimization_enabled') ?? true;
      _crashReportingEnabled = prefs.getBool('crash_reporting_enabled') ?? true;
    });
  }

  void _savePrivacySetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Privacy Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrivacyOverview(),
            const SizedBox(height: 24),
            _buildDataCollectionSection(),
            const SizedBox(height: 24),
            _buildDataManagementSection(),
            const SizedBox(height: 24),
            _buildRightsSection(),
            const SizedBox(height: 24),
            _buildSecuritySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOverview() {
    return _buildSectionCard(
      title: 'Your Privacy Matters',
      icon: Icons.security,
      children: [
        const Text(
          'InnerFive is committed to protecting your privacy. We collect only the data necessary to provide you with personalized insights, and we never share your personal information with third parties.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFF6366F1).withAlpha((255 * 0.3).round())),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your data is encrypted and stored securely',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataCollectionSection() {
    return _buildSectionCard(
      title: 'Data Collection Preferences',
      icon: Icons.data_usage,
      children: [
        _buildSwitchTile(
          'Usage Analytics',
          'Help us improve the app by sharing anonymous usage data',
          _analyticsEnabled,
          (value) {
            setState(() => _analyticsEnabled = value);
            _savePrivacySetting('analytics_enabled', value);
          },
        ),
        const Divider(color: Colors.grey),
        _buildSwitchTile(
          'Marketing Communications',
          'Receive updates about new features and insights',
          _marketingEnabled,
          (value) {
            setState(() => _marketingEnabled = value);
            _savePrivacySetting('marketing_enabled', value);
          },
        ),
        const Divider(color: Colors.grey),
        _buildSwitchTile(
          'Crash Reporting',
          'Send crash reports to help us fix bugs',
          _crashReportingEnabled,
          (value) {
            setState(() => _crashReportingEnabled = value);
            _savePrivacySetting('crash_reporting_enabled', value);
          },
        ),
        const Divider(color: Colors.grey),
        _buildSwitchTile(
          'Data Minimization',
          'Automatically delete unnecessary data after 90 days',
          _dataMinimizationEnabled,
          (value) {
            setState(() => _dataMinimizationEnabled = value);
            _savePrivacySetting('data_minimization_enabled', value);
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return _buildSectionCard(
      title: 'Data Management',
      icon: Icons.folder_outlined,
      children: [
        _buildActionTile(
          'Download My Data',
          'Get a copy of all your personal data',
          Icons.download,
          () => _showDataDownloadDialog(),
        ),
        const Divider(color: Colors.grey),
        _buildActionTile(
          'View Data Usage',
          'See what data we collect and how it\'s used',
          Icons.visibility,
          () => _showDataUsageDialog(),
        ),
        const Divider(color: Colors.grey),
        _buildActionTile(
          'Delete My Account',
          'Permanently delete your account and all data',
          Icons.delete_forever,
          () => _showDeleteAccountDialog(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildRightsSection() {
    return _buildSectionCard(
      title: 'Your Rights',
      icon: Icons.gavel,
      children: [
        _buildInfoTile(
          'Right to Access',
          'You can request access to your personal data at any time',
          Icons.lock_open,
        ),
        _buildInfoTile(
          'Right to Correction',
          'You can update or correct your personal information',
          Icons.edit,
        ),
        _buildInfoTile(
          'Right to Deletion',
          'You can request deletion of your personal data',
          Icons.delete_outline,
        ),
        _buildInfoTile(
          'Right to Portability',
          'You can export your data in a machine-readable format',
          Icons.import_export,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSectionCard(
      title: 'Security & Encryption',
      icon: Icons.enhanced_encryption,
      children: [
        const Text(
          'Your data protection details:',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        _buildSecurityItem('🔐', 'End-to-end encryption for sensitive data'),
        _buildSecurityItem('🛡️', 'Secure cloud storage with Firebase'),
        _buildSecurityItem('🔒', 'Two-factor authentication support'),
        _buildSecurityItem('📱', 'Local data encryption on your device'),
        _buildSecurityItem('🌐', 'HTTPS encryption for all communications'),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.white),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6366F1), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String emoji, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _showDataDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Download Your Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'We will prepare a complete export of your personal data and send it to your registered email address within 48 hours.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export request submitted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Request Export',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDataUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Data Usage',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '''We collect and use the following data:

• Birth date and time - for astrological calculations
• Name - for personalized reports
• Location - for timezone and regional insights
• Analysis results - to show your reports
• Usage statistics - to improve the app (if enabled)

All data is used solely to provide you with personalized insights and improve your experience.''',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'This action cannot be undone. All your data, including analysis reports and personal information, will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
