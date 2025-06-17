import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Map<String, List<String>> _eidosImageUrls = {};
  static final Map<String, List<String>> _tagImageUrls = {};
  static final Map<String, List<String>> _backgroundUrls = {};

  // For consistent background image per user per day
  static final Map<String, String> _userDailyBackground = {};

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

  /// 서비스 초기화 (앱 시작 시 호출)
  static Future<void> initialize() async {
    await preloadImages();
  }

  /// 사용자와 날짜 기반으로 일관된 운세 배경 이미지 URL 반환
  static Future<String?> getConsistentFortuneBackgroundUrl(
      String fortuneType, String? userName, String date) async {
    try {
      if (kDebugMode) {
        print(
            'ImageService: Getting fortune background for type: $fortuneType, user: $userName, date: $date');
      }

      // 운세 타입별 배경 이미지 파일명 정의 (Firebase Storage에 실제 존재하는 이미지들)
      final Map<String, List<String>> fortuneBackgrounds = {
        'love': List.generate(
            8, (i) => 'love${i + 1}.jpg'), // love1.jpg ~ love8.jpg
        'career': List.generate(
            8, (i) => 'career${i + 1}.jpg'), // career1.jpg ~ career8.jpg
        'wealth': List.generate(
            8, (i) => 'wealth${i + 1}.jpg'), // wealth1.jpg ~ wealth8.jpg
        'health': List.generate(
            8, (i) => 'health${i + 1}.jpg'), // health1.jpg ~ health8.jpg
        'social': List.generate(
            8, (i) => 'social${i + 1}.jpg'), // social1.jpg ~ social8.jpg
        'growth': List.generate(
            4, (i) => 'growth${i + 1}.jpg'), // growth1.jpg ~ growth4.jpg
      };

      final fortuneKey = fortuneType.toLowerCase();
      final backgrounds =
          fortuneBackgrounds[fortuneKey] ?? ['career1.jpg']; // 기본값

      if (kDebugMode) {
        print(
            'ImageService: Available backgrounds for $fortuneKey: $backgrounds');
      }

      // 사용자와 날짜 기반으로 일관된 이미지 선택
      final seed = '${userName ?? 'user'}_${date}_$fortuneKey'.hashCode;
      final random = Random(seed);
      final selectedImage = backgrounds[random.nextInt(backgrounds.length)];

      if (kDebugMode) {
        print('ImageService: Selected image: $selectedImage');
      }

      // Firebase Storage에서 이미지 URL 가져오기 (images/ 폴더 안에 있음)
      final path = 'images/$selectedImage';
      final url = await getImageUrl(path, isFullPath: true);

      if (kDebugMode) {
        print('ImageService: Final URL: $url');
      }

      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting consistent fortune background URL: $e');
      }
      return null;
    }
  }

  /// Get download URL for an image with caching
  static Future<String?> getImageUrl(String imagePath,
      {bool isFullPath = false}) async {
    try {
      final String finalPath =
          isFullPath ? imagePath : 'images/backgrounds/$imagePath';

      // Check direct URLs first (for uploaded compressed images)
      // Try both the simple name and the full path as keys
      final simpleKey = imagePath.replaceAll('.png', '').replaceAll('.jpg', '');
      final fullKey = finalPath.replaceAll('.png', '').replaceAll('.jpg', '');

      if (_directImageUrls.containsKey(simpleKey)) {
        final url = _directImageUrls[simpleKey]!;
        _urlCache[finalPath] = url;
        if (kDebugMode) {
          print('Using direct URL for $simpleKey: $url');
        }
        return url;
      }

      if (_directImageUrls.containsKey(fullKey)) {
        final url = _directImageUrls[fullKey]!;
        _urlCache[finalPath] = url;
        if (kDebugMode) {
          print('Using direct URL for $fullKey: $url');
        }
        return url;
      }

      // Check cache first
      if (_urlCache.containsKey(finalPath)) {
        if (kDebugMode) {
          print('Using cached URL for $finalPath');
        }
        return _urlCache[finalPath];
      }

      // Get download URL from Firebase Storage
      if (kDebugMode) {
        print('Fetching from Firebase Storage: $finalPath');
      }
      final ref = _storage.ref().child(finalPath);

      final url = await ref.getDownloadURL();
      _urlCache[finalPath] = url;

      if (kDebugMode) {
        print('Got download URL for $finalPath: $url');
      }

      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download URL for $imagePath: $e');
      }

      // Try to fallback to a direct URL if available
      final simpleKey = imagePath.replaceAll('.png', '').replaceAll('.jpg', '');
      if (_directImageUrls.containsKey(simpleKey)) {
        final url = _directImageUrls[simpleKey]!;
        if (kDebugMode) {
          print('Fallback to direct URL for $simpleKey: $url');
        }
        return url;
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

    final path = 'backgrounds/$selectedImage';
    return await getImageUrl(path, isFullPath: true);
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
        final path = 'backgrounds/$imageName';
        await getImageUrl(path, isFullPath: true);
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

  /// 이미지를 Firebase Storage에 업로드하고 URL 반환
  static Future<String?> uploadImage({
    required String imageName,
    required Uint8List imageData,
    String folder = 'images',
  }) async {
    try {
      final ref = _storage.ref().child('$folder/$imageName');
      await ref.putData(imageData);
      final url = await ref.getDownloadURL();
      _urlCache[imageName.split('.')[0]] = url;
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('이미지 업로드 실패: $e');
      }
      return null;
    }
  }

  /// 이미지 삭제
  static Future<bool> deleteImage(String imageName,
      {String folder = 'images'}) async {
    try {
      final ref = _storage.ref().child('$folder/$imageName');
      await ref.delete();
      _urlCache.remove(imageName.split('.')[0]);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('이미지 삭제 실패: $e');
      }
      return false;
    }
  }

  /// 폴더의 모든 이미지 목록 가져오기
  static Future<List<String>> listImages({String folder = 'images'}) async {
    try {
      final ref = _storage.ref().child(folder);
      final result = await ref.listAll();
      return result.items.map((item) => item.name).toList();
    } catch (e) {
      if (kDebugMode) {
        print('이미지 목록 가져오기 실패: $e');
      }
      return [];
    }
  }
}
