import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale? _currentLocale;

  Locale? get currentLocale => _currentLocale;

  // 지원하는 언어 목록
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ko', ''), // Korean
    Locale('ja', ''), // Japanese
    Locale('zh', ''), // Chinese
    Locale('ar', ''), // Arabic
  ];

  // 언어 코드를 표시명으로 변환
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ko':
        return '한국어';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      case 'ar':
        return 'العربية';
      default:
        return 'System Default';
    }
  }

  // 언어 초기화 (시스템 언어 또는 저장된 언어)
  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_languageKey);

    if (savedLanguageCode != null) {
      _currentLocale = Locale(savedLanguageCode);
    } else {
      // 시스템 기본 언어 사용
      _currentLocale = null;
    }

    notifyListeners();
  }

  // 언어 변경
  Future<void> changeLanguage(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    if (languageCode == null) {
      // 시스템 기본 언어로 설정
      _currentLocale = null;
      await prefs.remove(_languageKey);
    } else {
      _currentLocale = Locale(languageCode);
      await prefs.setString(_languageKey, languageCode);
    }

    notifyListeners();
  }

  // 현재 언어가 시스템 기본 언어인지 확인
  bool get isSystemDefault => _currentLocale == null;

  // 현재 언어 코드 반환 (시스템 기본인 경우 null)
  String? get currentLanguageCode => _currentLocale?.languageCode;
}
