import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class FortuneBackgroundService {
  static Map<String, List<String>>? _backgroundUrls;
  static final Random _random = Random();

  /// 운세 배경 이미지 URL들을 로드
  static Future<void> loadBackgroundUrls() async {
    if (_backgroundUrls != null) return;

    try {
      final String response = await rootBundle.loadString(
        'assets/fortune_background_urls.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      _backgroundUrls = data.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );

      print('🎯 FortuneBackgroundService loaded successfully:');
      _backgroundUrls!.forEach((key, urls) {
        print('  - $key: ${urls.length} images');
      });
    } catch (e) {
      print("❌ Error loading fortune background URLs: $e");
      _backgroundUrls = {};
    }
  }

  /// 특정 운세 타입에 대한 랜덤 배경 이미지 URL 반환
  static String? getRandomBackgroundUrl(String fortuneType) {
    if (_backgroundUrls == null) return null;

    final fortuneKey = fortuneType.toLowerCase();
    final urls = _backgroundUrls![fortuneKey];

    if (urls == null || urls.isEmpty) return null;

    return urls[_random.nextInt(urls.length)];
  }

  /// 사용자와 날짜 기반으로 일관된 배경 이미지 URL 반환
  static String? getConsistentBackgroundUrl(
      String fortuneType, String userName, String date) {
    if (_backgroundUrls == null) {
      print('❌ Background URLs not loaded yet');
      return null;
    }

    final fortuneKey = fortuneType.toLowerCase();
    final urls = _backgroundUrls![fortuneKey];

    if (urls == null || urls.isEmpty) {
      print('❌ No URLs found for fortune type: $fortuneKey');
      print('Available keys: ${_backgroundUrls!.keys.toList()}');
      return null;
    }

    // 사용자명 + 날짜 + 운세타입으로 시드 생성
    final seed = '${userName}_${date}_$fortuneKey'.hashCode;
    final random = Random(seed);
    final selectedUrl = urls[random.nextInt(urls.length)];

    print('✅ Selected background URL: $selectedUrl');
    return selectedUrl;
  }

  /// 모든 배경 URL 반환 (디버깅용)
  static Map<String, List<String>>? getAllBackgroundUrls() {
    return _backgroundUrls;
  }

  /// 특정 운세 타입의 모든 배경 URL 반환
  static List<String>? getBackgroundUrlsForType(String fortuneType) {
    if (_backgroundUrls == null) return null;

    final fortuneKey = fortuneType.toLowerCase();
    return _backgroundUrls![fortuneKey];
  }
}
