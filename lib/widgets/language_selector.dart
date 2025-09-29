import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:innerfive/services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);

    return ListTile(
      leading: const Icon(
        Icons.language,
        color: Colors.white70,
      ),
      title: Text(
        l10n.language,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        languageService.isSystemDefault
            ? l10n.languageSystem
            : languageService.getLanguageDisplayName(
                languageService.currentLanguageCode ?? 'en'),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16,
      ),
      onTap: () => _showLanguageDialog(context, l10n, languageService),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n,
      LanguageService languageService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A3E),
          title: Text(
            l10n.selectLanguage,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 시스템 기본값
              _buildLanguageOption(
                context,
                l10n.languageSystem,
                null,
                languageService.isSystemDefault,
                languageService,
              ),
              const Divider(color: Colors.white24),
              // 영어
              _buildLanguageOption(
                context,
                l10n.languageEnglish,
                'en',
                languageService.currentLanguageCode == 'en',
                languageService,
              ),
              // 한국어
              _buildLanguageOption(
                context,
                l10n.languageKorean,
                'ko',
                languageService.currentLanguageCode == 'ko',
                languageService,
              ),
              // 일본어
              _buildLanguageOption(
                context,
                l10n.languageJapanese,
                'ja',
                languageService.currentLanguageCode == 'ja',
                languageService,
              ),
              // 중국어
              _buildLanguageOption(
                context,
                l10n.languageChinese,
                'zh',
                languageService.currentLanguageCode == 'zh',
                languageService,
              ),
              // 아랍어
              _buildLanguageOption(
                context,
                l10n.languageArabic,
                'ar',
                languageService.currentLanguageCode == 'ar',
                languageService,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String displayName,
    String? languageCode,
    bool isSelected,
    LanguageService languageService,
  ) {
    return ListTile(
      title: Text(
        displayName,
        style: TextStyle(
          color: isSelected ? const Color(0xFF4ECDC4) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check,
              color: Color(0xFF4ECDC4),
            )
          : null,
      onTap: () async {
        await languageService.changeLanguage(languageCode);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
