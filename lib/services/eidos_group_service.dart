import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/detailed_report.dart';
import 'package:innerfive/models/eidos_summary.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/services/auth_service.dart';

import 'image_service.dart';

// Helper class to hold the processed data
class EidosGroupData {
  final EidosSummary summary;
  final String backgroundImageUrl;
  final Map<String, String?> cardImageUrls;
  final List<String> eidosTypesInGroup;
  final DetailedReport detailedReport;

  EidosGroupData({
    required this.summary,
    required this.backgroundImageUrl,
    required this.cardImageUrls,
    required this.eidosTypesInGroup,
    required this.detailedReport,
  });
}

class EidosGroupService {
  static const String _baseUrl =
      'https://storage.googleapis.com/innerfive.firebasestorage.app/edios_group_image/';

  // 백엔드에서 반환되는 새로운 에이도스 타입들과 이미지 매핑
  static const Map<String, String> _eidosTypeToImageMapping = {
    // A 그룹 - 창조자 계열
    'The Ambitious Verdant Architect': 'resolute_designer',
    'The Inspired Verdant Architect': 'creative_affluent',
    'The Resilient Verdant Architect': 'destiny_integrator',
    'The Fiery Artist': 'radiant_creator',
    'The Gregarious Visionary': 'great_manifestor',
    'The Passionate Seeker': 'indomitable_explorer',
    'The Radiant Creator': 'radiant_creator',
    'The Great Manifestor': 'great_manifestor',
    'The Creative Affluent': 'creative_affluent',
    'The Resolute Designer': 'resolute_designer',
    'The Inner Alchemist': 'inner_alchemist',
    'The Free Innovator': 'free_innovator',
    'The Destiny Integrator': 'destiny_integrator',
    'The Indomitable Explorer': 'indomitable_explorer',
    'The Relationship Artisan': 'relationship_artisan',

    // B 그룹 - 리더 계열
    'The Pragmatic Magnate': 'golden_pioneer',
    'The Visionary Entrepreneur': 'honorable_strategist',
    'The Social Influencer': 'flexible_strategist',
    'The Golden Pioneer': 'golden_pioneer',
    'The Honorable Strategist': 'honorable_strategist',
    'The Flexible Strategist': 'flexible_strategist',

    // C 그룹 - 통합자 계열
    'The Fair Collaborator': 'wise_guide',
    'The Harmonious Builder': 'wise_ruler',
    'The Wise Guide': 'wise_guide',
    'The Wise Ruler': 'wise_ruler',

    // D 그룹 - 탐험가 계열
    'The Action-Oriented Ideator': 'free_innovator',
    'The Ethical Administrator': 'wise_ruler',
    'The Light Bearer': 'spiritual_enlightener',
    'The Spiritual Enlightener': 'spiritual_enlightener',
    'The Strong-willed Lighthouse': 'strong-willed_lighthouse',
    'The Compassionate Healer': 'compassionate_healer',
    'The Deep-rooted Nurturer': 'deep-rooted_nurturer',
    'The Green Mercenary': 'green_mercenary',
    'The Abyss Explorer': 'abyss_explorer',

    // 추가 매핑 (백엔드에서 반환될 수 있는 다른 타입들)
    'The Compassionate Advisor': 'compassionate_healer',
    'The Passionate Seeker of Radiant Creator': 'radiant_creator',
    'The Compassionate Advisor of Wise Guide': 'wise_guide',
  };

  // 이미지 그룹별 Firebase Storage 경로
  static const Map<String, List<String>> _eidosImageMapping = {
    'abyss_explorer': [
      'eidos_group_image/Abyss_Explorer1.png',
      'eidos_group_image/Abyss_Explorer2.png',
      'eidos_group_image/Abyss_Explorer3.png',
      'eidos_group_image/Abyss_Explorer4.png',
    ],
    'compassionate_healer': [
      'eidos_group_image/Compassionate_Healer1.png',
      'eidos_group_image/Compassionate_Healer2.png',
      'eidos_group_image/Compassionate_Healer3.png',
      'eidos_group_image/Compassionate_Healer4.png',
    ],
    'creative_affluent': [
      'eidos_group_image/Creative_Affluent1.png',
      'eidos_group_image/Creative_Affluent2.png',
      'eidos_group_image/Creative_Affluent3.png',
      'eidos_group_image/Creative_Affluent4.png',
    ],
    'deep-rooted_nurturer': [
      'eidos_group_image/Deep-rooted_Nurturer1.png',
      'eidos_group_image/Deep-rooted_Nurturer2.png',
      'eidos_group_image/Deep-rooted_Nurturer3.png',
      'eidos_group_image/Deep-rooted_Nurturer4.png',
    ],
    'destiny_integrator': [
      'eidos_group_image/Destiny_Integrator1.png',
      'eidos_group_image/Destiny_Integrator2.png',
      'eidos_group_image/Destiny_Integrator3.png',
      'eidos_group_image/Destiny_Integrator4.png',
    ],
    'flexible_strategist': [
      'eidos_group_image/Flexible_Strategist1.png',
      'eidos_group_image/Flexible_Strategist2.png',
      'eidos_group_image/Flexible_Strategist3.png',
      'eidos_group_image/Flexible_Strategist4.png',
    ],
    'free_innovator': [
      'eidos_group_image/Free_Innovator1.png',
      'eidos_group_image/Free_Innovator2.png',
      'eidos_group_image/Free_Innovator3.png',
      'eidos_group_image/Free_Innovator4.png',
    ],
    'golden_pioneer': [
      'eidos_group_image/Golden_Pioneer1.png',
      'eidos_group_image/Golden_Pioneer2.png',
      'eidos_group_image/Golden_Pioneer3.png',
      'eidos_group_image/Golden_Pioneer4.png',
    ],
    'great_manifestor': [
      'eidos_group_image/Great_Manifestor1.png',
      'eidos_group_image/Great_Manifestor2.png',
      'eidos_group_image/Great_Manifestor3.png',
      'eidos_group_image/Great_Manifestor4.png',
    ],
    'green_mercenary': [
      'eidos_group_image/Green_Mercenary1.png',
      'eidos_group_image/Green_Mercenary2.png',
      'eidos_group_image/Green_Mercenary3.png',
      'eidos_group_image/Green_Mercenary4.png',
    ],
    'honorable_strategist': [
      'eidos_group_image/Honorable_Strategist1.png',
      'eidos_group_image/Honorable_Strategist2.png',
      'eidos_group_image/Honorable_Strategist3.png',
      'eidos_group_image/Honorable_Strategist4.png',
    ],
    'indomitable_explorer': [
      'eidos_group_image/Indomitable_Explorer1.png',
      'eidos_group_image/Indomitable_Explorer2.png',
      'eidos_group_image/Indomitable_Explorer3.png',
      'eidos_group_image/Indomitable_Explorer4.png',
    ],
    'inner_alchemist': [
      'eidos_group_image/Inner_Alchemist1.png',
      'eidos_group_image/Inner_Alchemist2.png',
      'eidos_group_image/Inner_Alchemist3.png',
      'eidos_group_image/Inner_Alchemist4.png',
    ],
    'radiant_creator': [
      'eidos_group_image/Radiant_Creator1.png',
      'eidos_group_image/Radiant_Creator2.png',
      'eidos_group_image/Radiant_Creator3.png',
      'eidos_group_image/Radiant_Creator4.png',
    ],
    'relationship_artisan': [
      'eidos_group_image/Relationship_Artisan1.png',
      'eidos_group_image/Relationship_Artisan2.png',
      'eidos_group_image/Relationship_Artisan3.png',
      'eidos_group_image/Relationship_Artisan4.png',
    ],
    'resolute_designer': [
      'eidos_group_image/Resolute_Designer1.png',
      'eidos_group_image/Resolute_Designer2.png',
      'eidos_group_image/Resolute_Designer3.png',
      'eidos_group_image/Resolute_Designer4.png',
    ],
    'spiritual_enlightener': [
      'eidos_group_image/Spiritual_Enlightener1.png',
      'eidos_group_image/Spiritual_Enlightener2.png',
      'eidos_group_image/Spiritual_Enlightener3.png',
      'eidos_group_image/Spiritual_Enlightener4.png',
    ],
    'strong-willed_lighthouse': [
      'eidos_group_image/Strong-willed_Lighthouse1.png',
      'eidos_group_image/Strong-willed_Lighthouse2.png',
      'eidos_group_image/Strong-willed_Lighthouse3.png',
      'eidos_group_image/Strong-willed_Lighthouse4.png',
    ],
    'wise_guide': [
      'eidos_group_image/Wise_Guide1.png',
      'eidos_group_image/Wise_Guide2.png',
      'eidos_group_image/Wise_Guide3.png',
      'eidos_group_image/Wise_Guide4.png',
    ],
    'wise_ruler': [
      'eidos_group_image/Wise_Ruler1.png',
      'eidos_group_image/Wise_Ruler2.png',
      'eidos_group_image/Wise_Ruler3.png',
      'eidos_group_image/Wise_Ruler4.png',
    ],
  };

  // 그룹별 한국어 표시 이름
  static const Map<String, String> _groupDisplayNames = {
    'abyss_explorer': '심연 탐험가',
    'compassionate_healer': '자비로운 치유자',
    'creative_affluent': '창조적 풍요자',
    'deep-rooted_nurturer': '깊이 뿌리내린 양육자',
    'destiny_integrator': '운명 통합자',
    'flexible_strategist': '유연한 전략가',
    'free_innovator': '자유로운 혁신가',
    'golden_pioneer': '황금 개척자',
    'great_manifestor': '위대한 현현자',
    'green_mercenary': '녹색 용병',
    'honorable_strategist': '명예로운 전략가',
    'indomitable_explorer': '불굴의 탐험가',
    'inner_alchemist': '내면 연금술사',
    'radiant_creator': '빛나는 창조자',
    'relationship_artisan': '관계 장인',
    'resolute_designer': '확고한 설계자',
    'spiritual_enlightener': '영적 깨달음자',
    'strong-willed_lighthouse': '의지가 강한 등대',
    'wise_guide': '현명한 안내자',
    'wise_ruler': '현명한 통치자',
  };

  // 그룹별 설명
  static const Map<String, String> _groupDescriptions = {
    'abyss_explorer': '깊은 내면의 세계를 탐험하며 숨겨진 진실을 찾아내는 존재',
    'compassionate_healer': '타인의 상처를 치유하고 따뜻한 위로를 전하는 존재',
    'creative_affluent': '창조적 에너지로 풍요로운 삶을 만들어가는 존재',
    'deep-rooted_nurturer': '깊은 뿌리로 다른 이들을 보살피고 성장시키는 존재',
    'destiny_integrator': '운명의 흐름을 통합하여 조화로운 길을 만드는 존재',
    'flexible_strategist': '유연한 사고로 최적의 전략을 세우는 존재',
    'free_innovator': '자유로운 영혼으로 혁신적인 변화를 이끄는 존재',
    'golden_pioneer': '황금빛 지혜로 새로운 길을 개척하는 존재',
    'great_manifestor': '위대한 비전을 현실로 구현해내는 존재',
    'green_mercenary': '자연과 조화하며 새로운 길을 개척하는 존재',
    'honorable_strategist': '명예로운 마음으로 전략적 사고를 펼치는 존재',
    'indomitable_explorer': '불굴의 의지로 미지의 영역을 탐험하는 존재',
    'inner_alchemist': '내면의 변화를 통해 진정한 가치를 창조하는 존재',
    'radiant_creator': '빛나는 영감으로 아름다운 창조물을 만드는 존재',
    'relationship_artisan': '인간관계의 예술가로 조화로운 연결을 만드는 존재',
    'resolute_designer': '확고한 의지로 미래를 설계하고 구현하는 존재',
    'spiritual_enlightener': '영적 깨달음을 통해 다른 이들을 인도하는 존재',
    'strong-willed_lighthouse': '강한 의지로 어둠 속에서 길을 밝히는 존재',
    'wise_guide': '현명한 지혜로 다른 이들의 길을 안내하는 존재',
    'wise_ruler': '현명한 통치력으로 조화로운 질서를 만드는 존재',
  };

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  static const Map<String, String> _cardTitleToImagePrefix = {
    'Core Identity': 'core_identity',
    'Why You Belong to This Group': 'why_you_belong_to_this_group',
    'Key Traits': 'key_traits',
    'Your Strengths': 'strengths',
    'Areas for Growth': 'growth',
    'Life Guidance': 'life_guidance',
  };

  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> map) {
    final newMap = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Timestamp) {
        newMap[key] = value.toDate().toIso8601String();
      } else if (value is Map<String, dynamic>) {
        newMap[key] = _convertTimestamps(value);
      } else {
        newMap[key] = value;
      }
    });
    return newMap;
  }

  List<String> getEidosTypesForGroup(String imageGroupKey) {
    final List<String> types = [];
    _eidosTypeToImageMapping.forEach((eidosType, group) {
      if (group == imageGroupKey) {
        types.add(eidosType);
      }
    });
    // Remove the user's own exact type from the list to avoid duplication
    types.removeWhere((type) => type.contains("of"));
    return types..sort();
  }

  Future<EidosGroupData?> getEidosGroupData() async {
    try {
      // 1. Get user profile
      final userProfile = await _authService.getUserProfile();
      if (userProfile == null) {
        throw Exception("User profile not found.");
      }

      // Convert Timestamps to a JSON-serializable format first
      final serializableUserProfile = _convertTimestamps(userProfile);

      // Prepare the request data for the analysis API
      final requestData = {
        'name': serializableUserProfile['displayName'] ??
            serializableUserProfile['nickname'],
        'year': int.tryParse(
            serializableUserProfile['birthDate']?.split('-')[0] ?? ''),
        'month': int.tryParse(
            serializableUserProfile['birthDate']?.split('-')[1] ?? ''),
        'day': int.tryParse(
            serializableUserProfile['birthDate']?.split('-')[2] ?? ''),
        'hour': 12, // Default hour
        'gender': serializableUserProfile['gender'],
        'birth_city': serializableUserProfile['city'],
      };

      // Remove null values to prevent API errors
      requestData.removeWhere((key, value) => value == null);

      if (!requestData.containsKey('year') ||
          !requestData.containsKey('month') ||
          !requestData.containsKey('day')) {
        throw Exception(
            "Missing required birth information to get Eidos group data.");
      }

      // 2. Get analysis report
      final analysisReport = await _apiService.getAnalysisReport(requestData);
      final eidosSummaryData = analysisReport['eidos_summary'];

      if (eidosSummaryData == null ||
          eidosSummaryData is! Map<String, dynamic>) {
        throw Exception("Eidos summary not found in analysis report.");
      }
      final summary = EidosSummary.fromJson(eidosSummaryData);
      final detailedReport = DetailedReport.fromJson(analysisReport);

      // 3. Get Background Image URL
      final imageGroupKey = getImageGroupFromEidosType(summary.summaryTitle);
      final imagePaths = _eidosImageMapping[imageGroupKey];
      if (imagePaths == null || imagePaths.isEmpty) {
        throw Exception(
            "Image mapping not found for group: ${summary.summaryTitle}");
      }
      final seed = userProfile['uid']?.hashCode ?? summary.groupId.hashCode;
      final deterministicRandom = Random(seed);
      final imagePath =
          imagePaths[deterministicRandom.nextInt(imagePaths.length)];
      final backgroundImageUrl =
          await ImageService.getImageUrl(imagePath, isFullPath: true);
      if (backgroundImageUrl == null) {
        throw Exception("Could not get image URL for path: $imagePath");
      }

      // 4. Get Card Image URLs in parallel
      final cardImageUrls = <String, String?>{};
      final futures = <Future>[];
      _cardTitleToImagePrefix.forEach((cardTitle, imagePrefix) {
        final cardSeed = seed + cardTitle.hashCode;
        final imageNumber = Random(cardSeed).nextInt(8) + 1; // 1 to 8
        final cardImagePath = 'inner_compass/$imagePrefix$imageNumber.png';
        futures.add(
          ImageService.getImageUrl(cardImagePath, isFullPath: true).then((url) {
            cardImageUrls[cardTitle] = url;
          }),
        );
      });
      await Future.wait(futures);

      // 5. Get Unique Eidos Type Card Image URL with fallback
      if (summary.eidosType.isNotEmpty) {
        final groupName = summary.summaryTitle.split(':')[0].trim();
        final typeName = summary.eidosType;
        final fileNameBase = '$typeName of $groupName';
        final variation = deterministicRandom.nextInt(4) + 1;
        final finalFileName = '${fileNameBase}_$variation.png';
        final uniqueCardImagePath = 'eidos_cards/$finalFileName';

        String? uniqueCardUrl;

        try {
          uniqueCardUrl = await ImageService.getImageUrl(uniqueCardImagePath,
              isFullPath: true);
        } catch (e) {
          print(
              "⚠️ Could not find unique Eidos card '$uniqueCardImagePath'. Error: $e");
        }

        if (uniqueCardUrl == null || uniqueCardUrl.isEmpty) {
          print("➡️ Using a random 'Inner Compass' card as fallback.");
          final availableInnerCompassCards = cardImageUrls.values
              .where((url) => url != null && url.isNotEmpty)
              .toList();
          if (availableInnerCompassCards.isNotEmpty) {
            uniqueCardUrl = availableInnerCompassCards[
                Random().nextInt(availableInnerCompassCards.length)];
            print("✅ Successfully selected fallback card.");
          } else {
            print("❌ No 'Inner Compass' cards available for fallback.");
          }
        }
        summary.cardImageUrl = uniqueCardUrl ?? '';
      }

      // 6. Get Eidos types for the same group
      final eidosTypesInGroup = getEidosTypesForGroup(imageGroupKey);

      // 7. Return the combined data
      return EidosGroupData(
        summary: summary,
        backgroundImageUrl: backgroundImageUrl,
        cardImageUrls: cardImageUrls,
        eidosTypesInGroup: eidosTypesInGroup,
        detailedReport: detailedReport,
      );
    } catch (e) {
      print("Error in getEidosGroupData: $e");
      rethrow;
    }
  }

  /// 에이도스 타입 이름으로부터 이미지 그룹을 결정
  static String getImageGroupFromEidosType(String eidosTypeName) {
    // 직접 매핑이 있는 경우
    if (_eidosTypeToImageMapping.containsKey(eidosTypeName)) {
      return _eidosTypeToImageMapping[eidosTypeName]!;
    }

    // 키워드 기반 매핑 (fallback)
    final lowerName = eidosTypeName.toLowerCase();

    if (lowerName.contains('creator') || lowerName.contains('radiant')) {
      return 'radiant_creator';
    } else if (lowerName.contains('manifestor') ||
        lowerName.contains('great')) {
      return 'great_manifestor';
    } else if (lowerName.contains('pioneer') || lowerName.contains('golden')) {
      return 'golden_pioneer';
    } else if (lowerName.contains('strategist') ||
        lowerName.contains('honorable')) {
      return 'honorable_strategist';
    } else if (lowerName.contains('guide') || lowerName.contains('wise')) {
      return 'wise_guide';
    } else if (lowerName.contains('ruler') ||
        lowerName.contains('administrator')) {
      return 'wise_ruler';
    } else if (lowerName.contains('healer') ||
        lowerName.contains('compassionate')) {
      return 'compassionate_healer';
    } else if (lowerName.contains('explorer') || lowerName.contains('seeker')) {
      return 'indomitable_explorer';
    } else if (lowerName.contains('innovator') || lowerName.contains('free')) {
      return 'free_innovator';
    } else if (lowerName.contains('enlightener') ||
        lowerName.contains('spiritual') ||
        lowerName.contains('light')) {
      return 'spiritual_enlightener';
    } else if (lowerName.contains('mercenary') || lowerName.contains('green')) {
      return 'green_mercenary';
    } else if (lowerName.contains('alchemist') || lowerName.contains('inner')) {
      return 'inner_alchemist';
    }

    // 기본값
    return 'radiant_creator';
  }

  /// 특정 이미지 그룹의 랜덤 이미지 URL 반환
  static String getRandomImageUrl(String imageGroup) {
    // 임시로 기존 이미지 시스템 사용
    final groupMapping = {
      'radiant_creator': 'green_mercenary',
      'golden_pioneer': 'golden_pioneer',
      'wise_guide': 'advanced_integration',
      'wise_ruler': 'advanced_integration',
      'spiritual_enlightener': 'mastery_transcendence',
      'compassionate_healer': 'green_mercenary',
      'free_innovator': 'golden_pioneer',
      'great_manifestor': 'golden_pioneer',
      'indomitable_explorer': 'green_mercenary',
      'honorable_strategist': 'golden_pioneer',
    };

    final fallbackGroup = groupMapping[imageGroup] ?? 'green_mercenary';
    final variation = Random().nextInt(4) + 1;
    return '$_baseUrl$fallbackGroup$variation.png';
  }

  /// 특정 이미지 그룹의 특정 변형 이미지 URL 반환
  static String getSpecificImageUrl(String imageGroup, int variation) {
    // 임시로 기존 이미지 시스템 사용
    final groupMapping = {
      'radiant_creator': 'green_mercenary',
      'golden_pioneer': 'golden_pioneer',
      'wise_guide': 'advanced_integration',
      'wise_ruler': 'advanced_integration',
      'spiritual_enlightener': 'mastery_transcendence',
      'compassionate_healer': 'green_mercenary',
      'free_innovator': 'golden_pioneer',
      'great_manifestor': 'golden_pioneer',
      'indomitable_explorer': 'green_mercenary',
      'honorable_strategist': 'golden_pioneer',
    };

    final fallbackGroup = groupMapping[imageGroup] ?? 'green_mercenary';
    final clampedVariation = variation.clamp(1, 4);
    return '$_baseUrl$fallbackGroup$clampedVariation.png';
  }

  /// 에이도스 타입으로부터 결정적 이미지 URL 반환 (시드 기반)
  static Future<String> getDeterministicImageUrl(
      String eidosTypeName, int seed) async {
    final imageGroup = getImageGroupFromEidosType(eidosTypeName);

    // 실제 파일명 매핑
    final fileNameMapping = {
      'abyss_explorer': 'Abyss_Explorer',
      'compassionate_healer': 'Compassionate_Healer',
      'creative_affluent': 'Creative_Affluent',
      'deep_rooted_nurturer': 'Deep_rooted_Nurturer',
      'destiny_integrator': 'Destiny_Integrator',
      'flexible_strategist': 'Flexible_Strategist',
      'free_innovator': 'Free_Innovator',
      'golden_pioneer': 'Golden_Pioneer',
      'great_manifestor': 'Great_Manifestor',
      'green_mercenary': 'Green_Mercenary',
      'honorable_strategist': 'Honorable_Strategist',
      'indomitable_explorer': 'Indomitable_Explorer',
      'inner_alchemist': 'Inner_Alchemist',
      'radiant_creator': 'Radiant_Creator',
      'relationship_artisan': 'Relationship_Artisan',
      'resolute_designer': 'Resolute_Designer',
      'spiritual_enlightener': 'Spiritual_Enlightener',
      'strong_willed_lighthouse': 'Strong_willed_Lighthouse',
      'wise_guide': 'Wise_Guide',
      'wise_ruler': 'Wise_Ruler',
    };

    final fileName = fileNameMapping[imageGroup] ?? 'Radiant_Creator';
    final variation = (seed % 4) + 1; // 1-4 변형

    // Firebase Storage 경로
    final storagePath = 'edios_group_image/$fileName$variation.png';

    // ImageService를 통해 인증된 URL 가져오기
    try {
      final url = await ImageService.getImageUrl(storagePath, isFullPath: true);
      return url ?? _getDefaultImageUrl();
    } catch (e) {
      print('Error getting eidos image URL: $e');
      return _getDefaultImageUrl();
    }
  }

  /// 에이도스 타입의 모든 이미지 URL 반환
  static List<String> getAllImageUrls(String eidosTypeName) {
    final imageGroup = getImageGroupFromEidosType(eidosTypeName);

    // 실제 파일명 매핑
    final fileNameMapping = {
      'abyss_explorer': 'Abyss Explorer',
      'compassionate_healer': 'Compassionate Healer',
      'creative_affluent': 'Creative Affluent',
      'deep_rooted_nurturer': 'Deep-rooted Nurturer',
      'destiny_integrator': 'Destiny Integrator',
      'flexible_strategist': 'Flexible Strategist',
      'free_innovator': 'Free Innovator',
      'golden_pioneer': 'Golden Pioneer',
      'great_manifestor': 'Great Manifestor',
      'green_mercenary': 'Green Mercenary',
      'honorable_strategist': 'Honorable Strategist',
      'indomitable_explorer': 'Indomitable Explorer',
      'inner_alchemist': 'Inner Alchemist',
      'radiant_creator': 'Radiant Creator',
      'relationship_artisan': 'Relationship Artisan',
      'resolute_designer': 'Resolute Designer',
      'spiritual_enlightener': 'Spiritual Enlightener',
      'strong_willed_lighthouse': 'Strong-willed Lighthouse',
      'wise_guide': 'Wise Guide',
      'wise_ruler': 'Wise Ruler',
    };

    final fileName = fileNameMapping[imageGroup] ?? 'Radiant Creator';

    return List.generate(4, (index) {
      final variation = index + 1;
      // 파일명의 공백과 하이픈을 언더스코어로 변경하여 URL 인코딩 문제 해결
      final encodedFileName =
          fileName.replaceAll(' ', '_').replaceAll('-', '_');
      return 'https://storage.googleapis.com/innerfive.firebasestorage.app/edios_group_image/$encodedFileName$variation.png';
    });
  }

  /// 그룹 표시 이름 반환
  static String getGroupDisplayName(String imageGroup) {
    return _groupDisplayNames[imageGroup] ?? imageGroup;
  }

  /// 그룹 설명 반환
  static String getGroupDescription(String imageGroup) {
    return _groupDescriptions[imageGroup] ?? '';
  }

  /// 에이도스 타입의 완전한 정보 반환
  static Future<Map<String, dynamic>> getEidosTypeInfo(String eidosTypeName,
      {int? seed}) async {
    final imageGroup = getImageGroupFromEidosType(eidosTypeName);
    final actualSeed = seed ?? eidosTypeName.hashCode;

    return {
      'eidos_type_name': eidosTypeName,
      'image_group': imageGroup,
      'display_name': getGroupDisplayName(imageGroup),
      'description': getGroupDescription(imageGroup),
      'image_url': await getDeterministicImageUrl(eidosTypeName, actualSeed),
      'all_images': getAllImageUrls(eidosTypeName),
      'variation_count': _eidosImageMapping[imageGroup]?.length ?? 1,
    };
  }

  /// 기본 이미지 URL
  static String _getDefaultImageUrl() {
    return 'https://storage.googleapis.com/innerfive.firebasestorage.app/edios_group_image/Radiant_Creator1.png';
  }

  // 레거시 메서드들 (하위 호환성)
  @deprecated
  static String getGroupFromEidosType(String eidosTypeId) {
    return getImageGroupFromEidosType(eidosTypeId);
  }

  @deprecated
  static String getRandomGroupImageUrl(String groupName) {
    return getRandomImageUrl(groupName);
  }

  @deprecated
  static String getGroupImageUrl(String groupName, int variation) {
    return getSpecificImageUrl(groupName, variation);
  }

  @deprecated
  static List<String> getAllGroupImageUrls(String groupName) {
    return getAllImageUrls(groupName);
  }

  @deprecated
  static Future<Map<String, dynamic>> getGroupInfoFromEidosType(
      String eidosTypeId) async {
    return await getEidosTypeInfo(eidosTypeId);
  }

  @deprecated
  static Future<String> getDeterministicGroupImageUrl(
      String eidosTypeId, int seed) async {
    return await getDeterministicImageUrl(eidosTypeId, seed);
  }
}
