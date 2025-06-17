import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:innerfive/screens/legal/privacy_policy_screen.dart';
import 'package:innerfive/screens/legal/terms_of_use_screen.dart';
import 'package:provider/provider.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        _buildSectionContainer(
          children: [
            _buildListTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => AppSettings.openAppSettings(
                  type: AppSettingsType.notification),
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Legal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        _buildSectionContainer(
          children: [
            _buildListTile(
              icon: Icons.shield_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ));
              },
            ),
            _buildListTile(
              icon: Icons.description_outlined,
              title: 'Terms of Use',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TermsOfUseScreen(),
                ));
              },
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        _buildSectionContainer(
          children: [
            _buildListTile(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () async {
                await authService.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            _buildListTile(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              onTap: () => _showDeleteAccountDialog(context),
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Delete Account',
              style: TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This action is irreversible. To confirm, please enter your password.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Password cannot be empty' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await authService
                        .deleteUserAccount(passwordController.text);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Account deleted successfully.')),
                    );
                  } catch (e) {
                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool showDivider = true,
    Color? iconColor,
    Color? textColor,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Icon(icon, color: iconColor ?? Colors.white70),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                          color: textColor ?? Colors.white, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) const Divider(color: Colors.white24, height: 1),
      ],
    );
  }
}
