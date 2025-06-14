import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegalDocument {
  final String title;
  final String content;
  final String version;
  final DateTime updatedAt;
  final String language;
  final bool active;

  LegalDocument({
    required this.title,
    required this.content,
    required this.version,
    required this.updatedAt,
    required this.language,
    required this.active,
  });

  factory LegalDocument.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LegalDocument(
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      version: data['version'] ?? '1.0',
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      language: data['language'] ?? 'en',
      active: data['active'] ?? true,
    );
  }
}

class LegalDocumentsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'legal_documents';

  /// Terms of Use 문서 가져오기
  static Future<LegalDocument?> getTermsOfUse() async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection(_collectionName)
              .doc('terms_of_use')
              .get();

      if (doc.exists) {
        return LegalDocument.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Failed to fetch Terms of Use: $e');
      return null;
    }
  }

  /// Privacy Policy 문서 가져오기
  static Future<LegalDocument?> getPrivacyPolicy() async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection(_collectionName)
              .doc('privacy_policy')
              .get();

      if (doc.exists) {
        return LegalDocument.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Failed to fetch Privacy Policy: $e');
      return null;
    }
  }

  /// 특정 문서 가져오기 (범용)
  static Future<LegalDocument?> getDocument(String documentId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionName).doc(documentId).get();

      if (doc.exists) {
        return LegalDocument.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Failed to fetch document ($documentId): $e');
      return null;
    }
  }

  /// 모든 활성화된 법적 문서 가져오기
  static Future<List<LegalDocument>> getAllActiveDocuments() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(_collectionName)
              .where('active', isEqualTo: true)
              .get();

      return querySnapshot.docs
          .map((doc) => LegalDocument.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Failed to fetch legal documents list: $e');
      return [];
    }
  }

  /// 문서 버전 확인 및 업데이트 알림
  static Future<bool> hasDocumentUpdated(String documentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String versionKey = 'legal_doc_version_$documentId';
      String? savedVersion = prefs.getString(versionKey);

      LegalDocument? document = await getDocument(documentId);
      if (document != null) {
        if (savedVersion == null || savedVersion != document.version) {
          // 새 버전 저장
          await prefs.setString(versionKey, document.version);
          return savedVersion != null; // 첫 설치가 아닌 경우에만 true 반환
        }
      }
      return false;
    } catch (e) {
      print('Failed to check document version ($documentId): $e');
      return false;
    }
  }

  /// Terms of Use 업데이트 확인
  static Future<bool> hasTermsOfUseUpdated() async {
    return await hasDocumentUpdated('terms_of_use');
  }

  /// Privacy Policy 업데이트 확인
  static Future<bool> hasPrivacyPolicyUpdated() async {
    return await hasDocumentUpdated('privacy_policy');
  }

  /// 사용자가 최신 버전의 문서에 동의했다고 표시
  static Future<void> markDocumentAsAgreed(
    String documentId,
    String version,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String agreementKey = 'legal_doc_agreed_$documentId';
      await prefs.setString(agreementKey, version);
      await prefs.setString(
        'legal_doc_agreed_date_$documentId',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Failed to mark document as agreed ($documentId): $e');
    }
  }

  /// 사용자가 특정 버전의 문서에 동의했는지 확인
  static Future<bool> hasUserAgreedToVersion(
    String documentId,
    String version,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String agreementKey = 'legal_doc_agreed_$documentId';
      String? agreedVersion = prefs.getString(agreementKey);
      return agreedVersion == version;
    } catch (e) {
      print('Failed to check document agreement ($documentId): $e');
      return false;
    }
  }

  /// 문서 변경사항 스트림 (실시간 업데이트)
  static Stream<LegalDocument?> getDocumentStream(String documentId) {
    return _firestore
        .collection(_collectionName)
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return LegalDocument.fromFirestore(snapshot);
          }
          return null;
        });
  }

  /// Terms of Use 실시간 스트림
  static Stream<LegalDocument?> getTermsOfUseStream() {
    return getDocumentStream('terms_of_use');
  }

  /// Privacy Policy 실시간 스트림
  static Stream<LegalDocument?> getPrivacyPolicyStream() {
    return getDocumentStream('privacy_policy');
  }
}
