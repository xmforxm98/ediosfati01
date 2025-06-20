import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/models/detailed_report.dart';
import 'package:innerfive/models/eidos_summary.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/services/auth_service.dart';
import '../constants/eidos_card_mappings.dart';

import 'image_service.dart';

// Helper class to hold the processed data
class EidosGroupData {
  final EidosSummary summary;
  final String backgroundImageUrl;
  final Map<String, String?> cardImageUrls;
  final List<String> eidosTypesInGroup;
  final DetailedReport detailedReport;
  final Map<String, dynamic> originalAnalysisData;
  final String? cardDescription;
  final List<String>? cardKeywords;

  EidosGroupData({
    required this.summary,
    required this.backgroundImageUrl,
    required this.cardImageUrls,
    required this.eidosTypesInGroup,
    required this.detailedReport,
    required this.originalAnalysisData,
    this.cardDescription,
    this.cardKeywords,
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

  // Group English display names
  static const Map<String, String> _groupDisplayNames = {
    'abyss_explorer': 'Abyss Explorer',
    'compassionate_healer': 'Compassionate Healer',
    'creative_affluent': 'Creative Affluent',
    'deep-rooted_nurturer': 'Deep-rooted Nurturer',
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
    'strong-willed_lighthouse': 'Strong-willed Lighthouse',
    'wise_guide': 'Wise Guide',
    'wise_ruler': 'Wise Ruler',
  };

  // Group descriptions in English
  static const Map<String, String> _groupDescriptions = {
    'abyss_explorer':
        'Beings who explore the deep inner world and discover hidden truths',
    'compassionate_healer':
        'Beings who heal others\' wounds and offer warm comfort',
    'creative_affluent':
        'Beings who create abundant lives through creative energy',
    'deep-rooted_nurturer':
        'Beings who care for and nurture others with deep roots',
    'destiny_integrator':
        'Beings who integrate the flow of destiny to create harmonious paths',
    'flexible_strategist':
        'Beings who establish optimal strategies through flexible thinking',
    'free_innovator': 'Beings who lead innovative change with free spirits',
    'golden_pioneer': 'Beings who pioneer new paths with golden wisdom',
    'great_manifestor': 'Beings who manifest great visions into reality',
    'green_mercenary': 'Beings who pioneer new paths in harmony with nature',
    'honorable_strategist':
        'Beings who deploy strategic thinking with honorable hearts',
    'indomitable_explorer':
        'Beings who explore unknown territories with indomitable will',
    'inner_alchemist':
        'Beings who create true value through inner transformation',
    'radiant_creator':
        'Beings who create beautiful works with radiant inspiration',
    'relationship_artisan':
        'Beings who create harmonious connections as relationship artists',
    'resolute_designer':
        'Beings who design and implement the future with firm will',
    'spiritual_enlightener':
        'Beings who guide others through spiritual enlightenment',
    'strong-willed_lighthouse':
        'Beings who illuminate paths in darkness with strong will',
    'wise_guide': 'Beings who guide others\' paths with wise wisdom',
    'wise_ruler': 'Beings who create harmonious order with wise governance',
  };

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  /// Map individual types to their corresponding card types
  static String _mapIndividualTypeToCardType(String individualType) {
    // 먼저 EidosCardMappings에서 직접 찾기 (백엔드에서 온 실제 타입 우선)
    if (EidosCardMappings.cardUrls.containsKey(individualType)) {
      print("🎯 Direct match found in EidosCardMappings: $individualType");
      return individualType;
    }

    // 백엔드에서 올 수 있는 실제 타입들 (API 응답 기준)
    const Map<String, String> apiResponseToCardMapping = {
      // 백엔드 API에서 실제로 반환하는 타입들을 올바른 카드로 매핑
      "The Ambitious Verdant Architect": "The Ambitious Verdant Architect",
      "The Inspired Verdant Architect":
          "The Inspired Verdant Architect of Green Mercenary",
      "The Resilient Verdant Architect":
          "The Resilient Verdant Architect of Green Mercenary",
      "The Fiery Artist": "The Fiery Artist of Radiant Creator",
      "The Gregarious Visionary": "The Gregarious Visionary of Radiant Creator",
      "The Passionate Seeker": "The Passionate Seeker of Radiant Creator",
      "The Firm Foundation Manager":
          "The Firm Foundation Manager of Deep-rooted Nurturer",
      "The Gentle Healer": "The Gentle Healer of Deep-rooted Nurturer",
      "The Community Advocate":
          "The Community Advocate of Deep-rooted Nurturer",
      "The Principled Administrator":
          "The Principled Administrator of Resolute Designer",
      "The Discerning Analyst": "The Discerning Analyst of Resolute Designer",
      "The Pragmatic Builder": "The Pragmatic Builder of Resolute Designer",
      "The Solitary Sage": "The Solitary Sage of Abyss Explorer",
      "The Intuitive Oracle": "The Intuitive Oracle of Abyss Explorer",
      "The Flowing Philosopher": "The Flowing Philosopher of Abyss Explorer",
    };

    // API 응답 기준 매핑 확인
    final apiMappedType = apiResponseToCardMapping[individualType];
    if (apiMappedType != null &&
        EidosCardMappings.cardUrls.containsKey(apiMappedType)) {
      print("🎯 API response mapping: $individualType -> $apiMappedType");
      return apiMappedType;
    }

    // 기존 프론트엔드 개별 타입 매핑 (하위 호환성)
    const Map<String, String> individualToCardMapping = {
      // Day Master based individual types to their card counterparts
      "The Unyielding Pine": "The Passionate Seeker of Radiant Creator",
      "The Radiant Sun": "The Fiery Artist of Radiant Creator",
      "The Steadfast Mountain":
          "The Community Advocate of Deep-rooted Nurturer",
      "The Tempered Sword":
          "The Guardian of Principles of Honorable Strategist",
      "The Gentle Rain": "The Flowing Philosopher of Abyss Explorer",
      "The Adaptable Willow": "The Strategic Adaptor of Flexible Strategist",
      "The Illuminating Candle": "The Light Bearer of Spiritual Enlightener",
      "The Nurturing Garden": "The Gentle Healer of Deep-rooted Nurturer",
      "The Polished Gem": "The Pragmatic Builder of Resolute Designer",
      "The Boundless Ocean": "The Solitary Sage of Abyss Explorer",

      // Life Path based individual types to their card counterparts
      "The Independent Innovator": "The Inspiring Pioneer of Free Innovator",
      "The Intuitive Diplomat": "The True Unifier of Relationship Artisan",
      "The Creative Communicator":
          "The Gregarious Visionary of Radiant Creator",
      "The Pragmatic Builder": "The Pragmatic Builder of Resolute Designer",
      "The Freedom-Seeking Adventurer":
          "The Boundless Explorer of Free Innovator",
      "The Compassionate Guardian":
          "The Soulful Nurturer of Compassionate Healer",
      "The Introspective Sage": "The Serene Scholar of Wise Guide",
      "The Authoritative Powerhouse":
          "The Authoritative Mentor of Honorable Strategist",
      "The Humanistic Visionary": "The Global Transformer of Great Manifestor",
      "The Master Intuitive": "The Intuitive Oracle of Abyss Explorer",
      "The Master Builder": "The Architect of Spirit of Great Manifestor",
    };

    // 기존 매핑 확인
    final mappedType = individualToCardMapping[individualType];
    if (mappedType != null &&
        EidosCardMappings.cardUrls.containsKey(mappedType)) {
      print("🎯 Found legacy mapping: $individualType -> $mappedType");
      return mappedType;
    }

    // 부분 매칭 시도 (키워드 기반)
    final availableTypes = EidosCardMappings.getAllTypes();
    for (final availableType in availableTypes) {
      if (_isPartialMatch(individualType, availableType)) {
        print("🔍 Partial match found: $individualType -> $availableType");
        return availableType;
      }
    }

    print("❌ No mapping found for: $individualType");
    return individualType;
  }

  /// 부분 매칭 로직 개선
  static bool _isPartialMatch(String individualType, String availableType) {
    // 핵심 키워드들 추출
    final individualKeywords = _extractKeywords(individualType);
    final availableKeywords = _extractKeywords(availableType);

    // 최소 2개 이상의 키워드가 일치하면 매칭
    int matchCount = 0;
    for (final keyword in individualKeywords) {
      if (availableKeywords.contains(keyword)) {
        matchCount++;
      }
    }

    return matchCount >= 2;
  }

  /// 타입명에서 핵심 키워드 추출
  static List<String> _extractKeywords(String typeName) {
    final keywords = <String>[];
    final cleanName = typeName
        .toLowerCase()
        .replaceAll('the ', '')
        .replaceAll(' of ', ' ')
        .split(' ');

    for (final word in cleanName) {
      if (word.length > 3 && !['and', 'for', 'with'].contains(word)) {
        keywords.add(word);
      }
    }

    return keywords;
  }

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
      // 1. First try to get existing analysis report from Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          print('🔍 Checking for existing analysis for user: ${user.uid}');
          final readingsQuery = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('readings')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          print('📄 Found ${readingsQuery.docs.length} readings');
          if (readingsQuery.docs.isNotEmpty) {
            final latestReadingData = readingsQuery.docs.first.data();
            print(
                '📄 Latest reading data keys: ${latestReadingData.keys.toList()}');
            if (latestReadingData.containsKey('report') &&
                latestReadingData['report'] != null) {
              print('✅ Found existing report, using it for Eidos group data');
              final reportData =
                  latestReadingData['report'] as Map<String, dynamic>;

              // Use existing analysis report
              final analysisReport = reportData;
              print('Using existing analysis report for Eidos group data');

              // This is a group analysis structure, look for individual type in other ways
              print('📊 Found group analysis structure');
              print('📊 Report data keys: ${reportData.keys.toList()}');
              print('📊 Group name: ${reportData['eidos_group_name']}');

              // Check if personalized_introduction contains individual type info
              String? individualEidosType;
              if (reportData['personalized_introduction'] != null) {
                final intro = reportData['personalized_introduction']
                    as Map<String, dynamic>;
                print('📊 Personalized intro: $intro');

                // Extract individual type from opening text using "As a The [Type]" pattern
                final opening = intro['opening'] as String?;
                if (opening != null) {
                  // Look for "As a The [individual type]" pattern
                  final regex = RegExp(r'As a (The [^,\.]+)');
                  final match = regex.firstMatch(opening);
                  if (match != null) {
                    individualEidosType = match.group(1)?.trim();
                    print(
                        '📊 Found individual type in opening: $individualEidosType');
                  }
                }

                // Fallback: Check if title contains individual type
                if (individualEidosType == null) {
                  final title = intro['title'] as String?;
                  if (title != null &&
                      title.startsWith('The ') &&
                      title != reportData['eidos_group_name']) {
                    individualEidosType = title;
                    print(
                        '📊 Found individual type in intro title: $individualEidosType');
                  }
                }
              }

              // If still no individual type found, check classification_reasoning
              if (individualEidosType == null &&
                  reportData['classification_reasoning'] != null) {
                final reasoning = reportData['classification_reasoning']
                    as Map<String, dynamic>;
                print('📊 Classification reasoning: $reasoning');
              }

              print('📊 Final individual eidos type: $individualEidosType');

              // Modify the analysis report to use individual eidos type
              final EidosSummary summary;
              final DetailedReport detailedReport;

              if (individualEidosType != null) {
                // Create a modified copy for the summary with individual type
                final modifiedAnalysisReport =
                    Map<String, dynamic>.from(analysisReport);
                modifiedAnalysisReport['eidos_type'] = individualEidosType;
                print('Individual Eidos Type: $individualEidosType');

                // Continue with existing logic using the modified report
                summary = EidosSummary.fromJson(modifiedAnalysisReport);
                detailedReport = DetailedReport.fromJson(analysisReport);
              } else {
                // Fallback to original if no individual type found
                summary = EidosSummary.fromJson(analysisReport);
                detailedReport = DetailedReport.fromJson(analysisReport);
              }

              // Get Background Image URL based on existing analysis
              final imageGroupKey =
                  getImageGroupFromEidosType(summary.summaryTitle);
              final imagePaths = _eidosImageMapping[imageGroupKey];
              if (imagePaths == null || imagePaths.isEmpty) {
                throw Exception(
                    "Image mapping not found for group: ${summary.summaryTitle}");
              }
              final seed = user.uid.hashCode ?? summary.groupId.hashCode;
              final deterministicRandom = Random(seed);
              final imagePath =
                  imagePaths[deterministicRandom.nextInt(imagePaths.length)];
              final backgroundImageUrl =
                  await ImageService.getImageUrl(imagePath, isFullPath: true);
              if (backgroundImageUrl == null) {
                throw Exception("Could not get image URL for path: $imagePath");
              }

              // Get Card Image URLs in parallel
              final cardImageUrls = <String, String?>{};
              final futures = <Future>[];
              _cardTitleToImagePrefix.forEach((cardTitle, imagePrefix) {
                final cardSeed = seed + cardTitle.hashCode;
                final imageNumber = Random(cardSeed).nextInt(8) + 1; // 1 to 8
                final cardImagePath =
                    'inner_compass/$imagePrefix$imageNumber.png';
                futures.add(
                  ImageService.getImageUrl(cardImagePath, isFullPath: true)
                      .then((url) {
                    cardImageUrls[cardTitle] = url;
                  }),
                );
              });
              await Future.wait(futures);

              // Get Unique Eidos Type Card Image URL with fallback
              if (summary.eidosType.isNotEmpty) {
                String? uniqueCardUrl;

                // First try to find exact match in EidosCardMappings
                final cardUrls = EidosCardMappings.cardUrls[summary.eidosType];
                if (cardUrls != null && cardUrls.isNotEmpty) {
                  // Use deterministic selection based on user ID
                  final cardIndex =
                      deterministicRandom.nextInt(cardUrls.length);
                  uniqueCardUrl = cardUrls[cardIndex];
                  print(
                      "✅ Found exact match in EidosCardMappings: $uniqueCardUrl");
                } else {
                  // Fallback: Try different mapping variations
                  print(
                      "🔍 Trying mapping variations for: ${summary.eidosType}");

                  // Use consistent mapping function instead of hardcoded mapping
                  String mappedType =
                      _mapIndividualTypeToCardType(summary.eidosType);
                  if (mappedType != summary.eidosType) {
                    print("🔄 Mapped ${summary.eidosType} -> $mappedType");
                  }

                  final mappedCardUrls = EidosCardMappings.cardUrls[mappedType];
                  if (mappedCardUrls != null && mappedCardUrls.isNotEmpty) {
                    final cardIndex =
                        deterministicRandom.nextInt(mappedCardUrls.length);
                    uniqueCardUrl = mappedCardUrls[cardIndex];
                    print("✅ Found mapped match: $uniqueCardUrl");
                  } else {
                    // If no specific mapping found, try to get any random card
                    print("🎲 No mapping found, selecting random card");
                    final allCardTypes = EidosCardMappings.getAllTypes();
                    if (allCardTypes.isNotEmpty) {
                      final randomTypeIndex =
                          deterministicRandom.nextInt(allCardTypes.length);
                      final randomType = allCardTypes[randomTypeIndex];
                      final randomCardUrls =
                          EidosCardMappings.cardUrls[randomType];
                      if (randomCardUrls != null && randomCardUrls.isNotEmpty) {
                        final cardIndex =
                            deterministicRandom.nextInt(randomCardUrls.length);
                        uniqueCardUrl = randomCardUrls[cardIndex];
                        print("✅ Selected random card: $uniqueCardUrl");
                      }
                    }
                    // If no mapping found, use old Firebase method as final fallback
                    final groupName = summary.summaryTitle.split(':')[0].trim();
                    final typeName = summary.eidosType;
                    final fileNameBase = '$typeName of $groupName';
                    final variation = deterministicRandom.nextInt(4) + 1;
                    final finalFileName = '${fileNameBase}_$variation.png';
                    final uniqueCardImagePath = 'eidos_cards/$finalFileName';

                    try {
                      uniqueCardUrl = await ImageService.getImageUrl(
                          uniqueCardImagePath,
                          isFullPath: true);
                    } catch (e) {
                      print(
                          "⚠️ Could not find unique Eidos card '$uniqueCardImagePath'. Error: $e");
                    }
                  }
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

              // Get Eidos types for the same group
              final eidosTypesInGroup = getEidosTypesForGroup(imageGroupKey);

              // 백엔드 데이터에서 설명과 키워드 추출 (EidosCardScreen과 동일한 로직)
              String? cardDescription;
              List<String>? cardKeywords;

              // 1. 개인화된 설명 추출
              final personalizedIntro =
                  analysisReport['personalized_introduction']
                      as Map<String, dynamic>?;
              if (personalizedIntro != null) {
                final opening = personalizedIntro['opening'] as String?;
                if (opening != null && opening.isNotEmpty) {
                  cardDescription = opening;
                }
              }

              // 2. 코어 아이덴티티 섹션에서 추가 설명 추출 (fallback)
              if (cardDescription == null || cardDescription.isEmpty) {
                final coreIdentitySection =
                    analysisReport['core_identity_section']
                        as Map<String, dynamic>?;
                if (coreIdentitySection != null) {
                  final coreIdentityText =
                      coreIdentitySection['text'] as String?;
                  if (coreIdentityText != null && coreIdentityText.isNotEmpty) {
                    cardDescription = coreIdentityText;
                  }
                }
              }

              // 3. 키워드 추출 (strengths section에서)
              final strengthsSection =
                  analysisReport['strengths_section'] as Map<String, dynamic>?;
              if (strengthsSection != null) {
                final points = strengthsSection['points'] as List?;
                if (points != null && points.isNotEmpty) {
                  cardKeywords =
                      points.map((point) => point.toString()).toList();
                  // 키워드를 4개로 제한
                  if (cardKeywords.length > 4) {
                    cardKeywords = cardKeywords.take(4).toList();
                  }
                }
              }

              // Return the combined data using existing analysis
              return EidosGroupData(
                summary: summary,
                backgroundImageUrl: backgroundImageUrl,
                cardImageUrls: cardImageUrls,
                eidosTypesInGroup: eidosTypesInGroup,
                detailedReport: detailedReport,
                originalAnalysisData: analysisReport,
                cardDescription: cardDescription, // 추출한 설명
                cardKeywords: cardKeywords, // 추출한 키워드
              );
            } else {
              print('❌ No report found in latest reading data');
            }
          } else {
            print('❌ No readings found for user');
          }
        } catch (e) {
          print("❌ Error loading existing analysis, will create new one: $e");
        }
      } else {
        print('❌ User is null');
      }

      // 2. If no existing analysis found, get user profile and create new one
      print('⚠️ No existing analysis found, creating new one...');
      print('👤 Getting user profile...');
      final userProfile = await _authService.getUserProfile();
      if (userProfile == null) {
        throw Exception("User profile not found.");
      }
      print(
          '👤 User profile loaded successfully: ${userProfile.keys.toList()}');

      // Convert Timestamps to a JSON-serializable format first
      final serializableUserProfile = _convertTimestamps(userProfile);

      // Prepare the request data for the analysis API
      final birthDate = serializableUserProfile['birthDate'];
      final birthTime = serializableUserProfile['birthTime'];

      // Parse birth date
      int? year, month, day;
      if (birthDate != null && birthDate.toString().isNotEmpty) {
        final dateParts = birthDate.toString().split('-');
        if (dateParts.length >= 3) {
          year = int.tryParse(dateParts[0]);
          month = int.tryParse(dateParts[1]);
          day = int.tryParse(dateParts[2]);
        }
      }

      // Parse birth time - default to 12:00 if not available
      int hour = 12;
      if (birthTime != null &&
          birthTime.toString().isNotEmpty &&
          birthTime.toString() != 'null:null') {
        final timeParts = birthTime.toString().split(':');
        if (timeParts.isNotEmpty) {
          hour = int.tryParse(timeParts[0]) ?? 12;
        }
      }

      final requestData = {
        'name': serializableUserProfile['nickname'] ??
            serializableUserProfile['displayName'] ??
            'User',
        'year': year,
        'month': month,
        'day': day,
        'hour': hour,
        'gender': serializableUserProfile['gender'],
        'birth_city': serializableUserProfile['city'],
      };

      // Remove null values to prevent API errors
      requestData.removeWhere((key, value) => value == null);

      print('👤 User profile birth data:');
      print('   - birthDate: ${serializableUserProfile['birthDate']}');
      print('   - birthTime: ${serializableUserProfile['birthTime']}');
      print('   - city: ${serializableUserProfile['city']}');
      print('   - Parsed year/month/day: $year/$month/$day');
      print('Request data for analysis: $requestData');

      if (year == null || month == null || day == null) {
        throw Exception(
            "Missing required birth information to get Eidos group data. Please complete your profile first.");
      }

      // 3. Get analysis report (fallback if no existing report found)
      final analysisReport = await _apiService.getAnalysisReport(requestData);

      // The new API response is the root of the analysis data.
      final summary = EidosSummary.fromJson(analysisReport);
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
        String? uniqueCardUrl;

        // First try to find exact match in EidosCardMappings
        final cardUrls = EidosCardMappings.cardUrls[summary.eidosType];
        if (cardUrls != null && cardUrls.isNotEmpty) {
          // Use deterministic selection based on user ID
          final cardIndex = deterministicRandom.nextInt(cardUrls.length);
          uniqueCardUrl = cardUrls[cardIndex];
          print("✅ Found exact match in EidosCardMappings: $uniqueCardUrl");
        } else {
          // Fallback: Try different mapping variations
          print("🔍 Trying mapping variations for: ${summary.eidosType}");

          // Use consistent mapping function instead of hardcoded mapping
          String mappedType = _mapIndividualTypeToCardType(summary.eidosType);
          if (mappedType != summary.eidosType) {
            print("🔄 Mapped ${summary.eidosType} -> $mappedType");
          }

          final mappedCardUrls = EidosCardMappings.cardUrls[mappedType];
          if (mappedCardUrls != null && mappedCardUrls.isNotEmpty) {
            final cardIndex =
                deterministicRandom.nextInt(mappedCardUrls.length);
            uniqueCardUrl = mappedCardUrls[cardIndex];
            print("✅ Found mapped match: $uniqueCardUrl");
          } else {
            // If no specific mapping found, try to get any random card
            print("🎲 No mapping found, selecting random card");
            final allCardTypes = EidosCardMappings.getAllTypes();
            if (allCardTypes.isNotEmpty) {
              final randomTypeIndex =
                  deterministicRandom.nextInt(allCardTypes.length);
              final randomType = allCardTypes[randomTypeIndex];
              final randomCardUrls = EidosCardMappings.cardUrls[randomType];
              if (randomCardUrls != null && randomCardUrls.isNotEmpty) {
                final cardIndex =
                    deterministicRandom.nextInt(randomCardUrls.length);
                uniqueCardUrl = randomCardUrls[cardIndex];
                print("✅ Selected random card: $uniqueCardUrl");
              }
            }

            // If still no card found, use old Firebase method as final fallback
            if (uniqueCardUrl == null || uniqueCardUrl.isEmpty) {
              final groupName = summary.summaryTitle.split(':')[0].trim();
              final typeName = summary.eidosType;
              final fileNameBase = '$typeName of $groupName';
              final variation = deterministicRandom.nextInt(4) + 1;
              final finalFileName = '${fileNameBase}_$variation.png';
              final uniqueCardImagePath = 'eidos_cards/$finalFileName';

              try {
                uniqueCardUrl = await ImageService.getImageUrl(
                    uniqueCardImagePath,
                    isFullPath: true);
              } catch (e) {
                print(
                    "⚠️ Could not find unique Eidos card '$uniqueCardImagePath'. Error: $e");
              }
            }
          }
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
        originalAnalysisData: analysisReport,
        cardDescription: analysisReport['personalized_introduction']
            ?['description'] as String?,
        cardKeywords: analysisReport['personalized_introduction']?['keywords']
            as List<String>?,
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
