import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:innerfive/services/auth_service.dart';
import 'package:innerfive/screens/legal/privacy_policy_screen.dart';
import 'package:innerfive/screens/legal/terms_of_use_screen.dart';
import 'package:innerfive/widgets/language_selector.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settings,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        _buildSectionContainer(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: const LanguageSelector(),
            ),
            _buildDivider(),
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
              onTap: () => _handleLogOut(context, authService),
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

  Future<void> _handleLogOut(
      BuildContext context, AuthService authService) async {
    try {
      print('🔍 [DEBUG] _handleLogOut 메서드 호출됨');
      // 로그아웃 확인 다이얼로그 표시
      final shouldLogOut = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Log Out', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );

      if (shouldLogOut == true) {
        // 로그아웃 실행
        print('🚪 로그아웃 버튼 클릭됨');
        await authService.signOut();
        print('🚪 AuthService.signOut() 완료');

        // AuthWrapper가 자동으로 InitialScreen으로 이동하도록
        // 모든 라우트를 제거하고 첫 번째 라우트로 이동
        if (context.mounted) {
          print('🚪 네비게이션 리셋 시작');
          Navigator.of(context).popUntil((route) => route.isFirst);
          print('🚪 네비게이션 리셋 완료');
        }
      }
    } catch (e) {
      print('로그아웃 오류: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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

  Widget _buildDivider() {
    return const Divider(color: Colors.white24, height: 1);
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
