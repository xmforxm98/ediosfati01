import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class DynamicImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Map<String, String> _dynamicCache = {};

  /// 이미지를 Firebase Storage에 업로드하고 URL 반환
  static Future<String?> uploadImage({
    required String imageName,
    required Uint8List imageData,
    String folder = 'images',
  }) async {
    try {
      final ref = _storage.ref().child('$folder/$imageName');

      // 업로드
      await ref.putData(imageData);

      // URL 가져오기
      final url = await ref.getDownloadURL();

      // 캐시에 저장
      _dynamicCache[imageName.split('.')[0]] = url;

      return url;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      return null;
    }
  }

  /// 동적으로 업로드된 이미지 URL 가져오기
  static Future<String?> getDynamicImageUrl(String imageName) async {
    // 캐시에 있으면 반환
    if (_dynamicCache.containsKey(imageName)) {
      return _dynamicCache[imageName];
    }

    try {
      // Firebase에서 URL 가져오기
      final ref = _storage.ref().child('images/$imageName.png');
      final url = await ref.getDownloadURL();
      _dynamicCache[imageName] = url;
      return url;
    } catch (e) {
      print('동적 이미지 로드 실패: $imageName - $e');
      return null;
    }
  }

  /// 이미지 삭제
  static Future<bool> deleteImage(String imageName) async {
    try {
      final ref = _storage.ref().child('images/$imageName');
      await ref.delete();
      _dynamicCache.remove(imageName.split('.')[0]);
      return true;
    } catch (e) {
      print('이미지 삭제 실패: $e');
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
      print('이미지 목록 가져오기 실패: $e');
      return [];
    }
  }
}
