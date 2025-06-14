import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class TagImageManager {
  static Map<String, List<String>>? _tagImageUrls;
  static final Random _random = Random();

  /// 태그 이미지 URL 데이터를 로드합니다.
  static Future<void> loadTagImageUrls() async {
    if (_tagImageUrls != null) return; // 이미 로드된 경우 스킵

    try {
      final String response = await rootBundle.loadString(
        'assets/tag_image_urls.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      _tagImageUrls = data.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
      print("✓ 태그 이미지 URL 데이터 로드 완료");
    } catch (e) {
      print("✗ 태그 이미지 URL 데이터 로드 실패: $e");
      _tagImageUrls = {};
    }
  }

  /// 해시태그에서 원소 타입을 추출합니다.
  static String? _extractElementFromHashtag(String hashtag) {
    // #WoodEnergy, #FireEnergy 등에서 원소 타입 추출
    final cleanTag = hashtag.replaceAll('#', '');

    if (cleanTag.contains('Wood')) return 'WoodEnergy';
    if (cleanTag.contains('Fire')) return 'FireEnergy';
    if (cleanTag.contains('Earth')) return 'EarthEnergy';
    if (cleanTag.contains('Metal')) return 'MetalEnergy';
    if (cleanTag.contains('Water')) return 'WaterEnergy';
    if (cleanTag.contains('Neutral')) return 'NeutralEnergy';

    return null;
  }

  /// 해시태그 리스트에서 원소 에너지 해시태그를 찾아 해당 이미지 URL을 반환합니다.
  static String? getImageUrlForHashtags(List<String> hashtags) {
    if (_tagImageUrls == null) return null;

    // 해시태그에서 원소 에너지 태그 찾기
    for (String hashtag in hashtags) {
      final elementType = _extractElementFromHashtag(hashtag);
      if (elementType != null && _tagImageUrls!.containsKey(elementType)) {
        final imageUrls = _tagImageUrls![elementType]!;
        if (imageUrls.isNotEmpty) {
          // 랜덤하게 하나의 이미지 선택
          return imageUrls[_random.nextInt(imageUrls.length)];
        }
      }
    }

    return null;
  }

  /// 특정 원소 타입의 랜덤 이미지 URL을 반환합니다.
  static String? getRandomImageForElement(String elementType) {
    if (_tagImageUrls == null) return null;

    final imageUrls = _tagImageUrls![elementType];
    if (imageUrls != null && imageUrls.isNotEmpty) {
      return imageUrls[_random.nextInt(imageUrls.length)];
    }

    return null;
  }

  /// 모든 원소 타입 목록을 반환합니다.
  static List<String> getAllElementTypes() {
    return _tagImageUrls?.keys.toList() ?? [];
  }

  /// 특정 원소 타입의 모든 이미지 URL을 반환합니다.
  static List<String> getAllImagesForElement(String elementType) {
    return _tagImageUrls?[elementType] ?? [];
  }
}
