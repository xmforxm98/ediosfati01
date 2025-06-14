import 'dart:math';

class EidosGroupService {
  static const String _baseUrl =
      'https://storage.googleapis.com/innerfive.firebasestorage.app/eidos_group_images/';

  // Group mapping based on Eidos type patterns
  static const Map<String, String> _typeToGroupMapping = {
    // A 계열 - Green Mercenary variants
    'A-01': 'green_mercenary',
    'A-02': 'green_mercenary',
    'A-03': 'green_mercenary',
    'A-04': 'green_mercenary',
    'A-05': 'green_mercenary',

    // B 계열 - Golden Pioneer variants
    'B-01': 'golden_pioneer',
    'B-02': 'golden_pioneer',
    'B-03': 'golden_pioneer',
    'B-04': 'golden_pioneer',
    'B-05': 'golden_pioneer',

    // C 계열 - Advanced Integration variants
    'C-01': 'advanced_integration',
    'C-02': 'advanced_integration',
    'C-03': 'advanced_integration',
    'C-04': 'advanced_integration',

    // D 계열 - Mastery & Transcendence variants
    'D-01': 'mastery_transcendence',
    'D-02': 'mastery_transcendence',
    'D-03': 'mastery_transcendence',
    'D-04': 'mastery_transcendence',
    'D-05': 'mastery_transcendence',
    'D-06': 'mastery_transcendence',
  };

  // Number of variations per group
  static const Map<String, int> _groupVariationCounts = {
    'green_mercenary': 4,
    'golden_pioneer': 4,
    'advanced_integration': 6,
    'mastery_transcendence': 5,
  };

  // Group display names (English)
  static const Map<String, String> _groupDisplayNames = {
    'green_mercenary': 'Green Mercenary',
    'golden_pioneer': 'Golden Pioneer',
    'advanced_integration': 'Advanced Integration',
    'mastery_transcendence': 'Mastery Transcendence',
  };

  // Group descriptions (English)
  static const Map<String, String> _groupDescriptions = {
    'green_mercenary':
        'Beings who harmonize with the forces of nature and pioneer new paths',
    'golden_pioneer':
        'Beings who design the future with golden wisdom and create wealth and success',
    'advanced_integration':
        'Beings who achieve harmony by integrating spiritual enlightenment with practical abilities',
    'mastery_transcendence':
        'Beings who transcend all limitations to achieve ultimate mastery',
  };

  /// Determines the group based on Eidos type ID
  static String getGroupFromEidosType(String eidosTypeId) {
    // Extract the main type prefix (e.g., "A-01" from "A-01-S1")
    final parts = eidosTypeId.split('-');
    if (parts.length >= 2) {
      final mainType = '${parts[0]}-${parts[1]}';
      return _typeToGroupMapping[mainType] ?? 'green_mercenary';
    }

    // Fallback based on first letter
    final firstLetter = eidosTypeId.substring(0, 1).toUpperCase();
    switch (firstLetter) {
      case 'A':
        return 'green_mercenary';
      case 'B':
        return 'golden_pioneer';
      case 'C':
        return 'advanced_integration';
      case 'D':
        return 'mastery_transcendence';
      default:
        return 'green_mercenary';
    }
  }

  /// Gets a random image URL for the specified group
  static String getRandomGroupImageUrl(String groupName) {
    final variationCount = _groupVariationCounts[groupName] ?? 4;
    final randomVariation = Random().nextInt(variationCount) + 1;
    return '$_baseUrl$groupName$randomVariation.png';
  }

  /// Gets a specific variation image URL for the group
  static String getGroupImageUrl(String groupName, int variation) {
    final variationCount = _groupVariationCounts[groupName] ?? 4;
    final clampedVariation = variation.clamp(1, variationCount);
    return '$_baseUrl$groupName$clampedVariation.png';
  }

  /// Gets the display name for a group
  static String getGroupDisplayName(String groupName) {
    return _groupDisplayNames[groupName] ?? groupName;
  }

  /// Gets the description for a group
  static String getGroupDescription(String groupName) {
    return _groupDescriptions[groupName] ?? '';
  }

  /// Gets all available variation URLs for a group
  static List<String> getAllGroupImageUrls(String groupName) {
    final variationCount = _groupVariationCounts[groupName] ?? 4;
    return List.generate(
      variationCount,
      (index) => getGroupImageUrl(groupName, index + 1),
    );
  }

  /// Gets group info based on Eidos type
  static Map<String, dynamic> getGroupInfoFromEidosType(String eidosTypeId) {
    final groupName = getGroupFromEidosType(eidosTypeId);
    return {
      'group_name': groupName,
      'display_name': getGroupDisplayName(groupName),
      'description': getGroupDescription(groupName),
      'image_url': getRandomGroupImageUrl(groupName),
      'all_images': getAllGroupImageUrls(groupName),
      'variation_count': _groupVariationCounts[groupName] ?? 4,
    };
  }

  /// Gets a themed image based on Eidos type with deterministic selection
  static String getDeterministicGroupImageUrl(String eidosTypeId, int seed) {
    final groupName = getGroupFromEidosType(eidosTypeId);
    final variationCount = _groupVariationCounts[groupName] ?? 4;

    // Use the seed to deterministically select a variation
    final variation = (seed % variationCount) + 1;
    return getGroupImageUrl(groupName, variation);
  }
}
