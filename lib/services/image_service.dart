import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Cache for storing download URLs
  static final Map<String, String> _urlCache = {};

  // Login background images
  static const List<String> _loginBackgrounds = [
    'login1.png',
    'login2.png',
    'login3.png',
    'login4.png',
  ];

  // Image URLs directly from Firebase Storage
  static const Map<String, String> _directImageUrls = {
    'second_bg':
        'https://storage.googleapis.com/innerfive.firebasestorage.app/images/backgrounds/second_bg.jpg',
    'input_bg':
        'https://storage.googleapis.com/innerfive.firebasestorage.app/images/backgrounds/input_bg.jpg',
    'loading':
        'https://storage.googleapis.com/innerfive.firebasestorage.app/images/backgrounds/loading.jpg',
  };

  /// Get download URL for an image with caching
  static Future<String?> getImageUrl(String imagePath) async {
    try {
      // Check direct URLs first (for uploaded compressed images)
      final imageKey = imagePath.replaceAll('.png', '').replaceAll('.jpg', '');
      if (_directImageUrls.containsKey(imageKey)) {
        final url = _directImageUrls[imageKey]!;
        _urlCache[imagePath] = url;
        return url;
      }

      // Check cache first
      if (_urlCache.containsKey(imagePath)) {
        return _urlCache[imagePath];
      }

      // Get download URL from Firebase Storage
      final ref = _storage.ref().child('images/backgrounds/$imagePath');

      // 웹에서는 public URL 형식을 사용
      if (kIsWeb) {
        final url =
            'https://firebasestorage.googleapis.com/v0/b/innerfive.firebasestorage.app/o/images%2Fbackgrounds%2F$imagePath?alt=media';
        _urlCache[imagePath] = url;

        if (kDebugMode) {
          print('Using direct URL for $imagePath: $url');
        }

        return url;
      } else {
        // 모바일에서는 getDownloadURL 사용
        final url = await ref.getDownloadURL();
        _urlCache[imagePath] = url;

        if (kDebugMode) {
          print('Got download URL for $imagePath: $url');
        }

        return url;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download URL for $imagePath: $e');
      }
      return null;
    }
  }

  /// Get a random login background image URL
  static Future<String?> getRandomLoginBackground() async {
    final random = Random();
    final selectedImage =
        _loginBackgrounds[random.nextInt(_loginBackgrounds.length)];

    if (kDebugMode) {
      print('Selected random login background: $selectedImage');
    }

    return await getImageUrl(selectedImage);
  }

  /// Get second_bg image URL for initial screen
  static Future<String?> getSecondBackgroundUrl() async {
    return await getImageUrl('second_bg');
  }

  /// Get input_bg image URL for input screens
  static Future<String?> getInputBackgroundUrl() async {
    return await getImageUrl('input_bg');
  }

  /// Get loading image URL for loading screen
  static Future<String?> getLoadingBackgroundUrl() async {
    return await getImageUrl('loading');
  }

  /// Preload login background images
  static Future<void> preloadLoginBackgrounds() async {
    if (kDebugMode) {
      print('Preloading login background images...');
    }

    for (final imageName in _loginBackgrounds) {
      try {
        await getImageUrl(imageName);
        if (kDebugMode) {
          print('Preloaded: $imageName');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to preload $imageName: $e');
        }
      }
    }
  }

  /// Clear URL cache
  static void clearCache() {
    _urlCache.clear();
  }

  /// 특정 그룹의 랜덤 이미지 가져오기 (확장 가능)
  static Future<String> getRandomImageFromGroup(List<String> imageNames) async {
    if (imageNames.isEmpty) {
      throw Exception('이미지 그룹이 비어있습니다');
    }

    final random = Random();
    final selectedImage = imageNames[random.nextInt(imageNames.length)];

    return await getImageUrl(selectedImage) ?? '';
  }

  /// 이미지 미리 로드 (앱 시작 시 호출)
  static Future<void> preloadImages() async {
    final imageNames = [
      'login1',
      'login2',
      'login3',
      'login4', // 랜덤 로그인 배경들 (Firebase Storage에 업로드됨)
      'second_bg', // Initial screen background
      'input_bg', // Input screen background
      'loading', // Loading screen background
      // 다른 이미지들은 아직 Firebase Storage에 없으므로 주석 처리
      // 'name_input_bg',
      // 'birth_time',
      // 'city_bg',
      // 'birth_input_bg',
      // 'continue_to',
      // 'loading_bg',
      // 'gender_bg',
    ];

    // 모든 이미지 URL을 병렬로 가져와서 캐시에 저장
    // 실패한 이미지는 무시하고 계속 진행
    await Future.wait(
      imageNames.map(
        (name) => getImageUrl(name).catchError((e) {
          print('Failed to preload $name: $e');
          return '';
        }),
      ),
    );
  }
}
