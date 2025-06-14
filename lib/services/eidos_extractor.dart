class EidosExtractor {
  /// API 응답에서 Eidos Type을 추출합니다
  static String? extractEidosType(Map<String, dynamic> responseData) {
    // 1. 직접적인 eidos_type 필드 확인
    if (responseData.containsKey('eidos_type') &&
        responseData['eidos_type'] != null &&
        responseData['eidos_type'].toString().isNotEmpty) {
      return responseData['eidos_type'].toString();
    }

    // 2. eidos_summary 섹션에서 추출 시도
    final eidosSummary = responseData['eidos_summary'] as Map<String, dynamic>?;
    if (eidosSummary != null) {
      // summary_text에서 그룹 정보 추출 시도
      final summaryText = eidosSummary['summary_text']?.toString() ?? '';
      final extractedType = _extractTypeFromText(summaryText);
      if (extractedType != null) {
        return extractedType;
      }
    }

    // 3. innate_eidos 섹션에서 추출 시도
    final innateEidos = responseData['innate_eidos'] as Map<String, dynamic>?;
    if (innateEidos != null) {
      final coreEnergyText = innateEidos['core_energy_text']?.toString() ?? '';
      final extractedType = _extractTypeFromText(coreEnergyText);
      if (extractedType != null) {
        return extractedType;
      }
    }

    // 4. raw_data_for_dev에서 확인
    final rawData = responseData['raw_data_for_dev'] as Map<String, dynamic>?;
    if (rawData != null) {
      final extractedType = _searchInRawData(rawData);
      if (extractedType != null) {
        return extractedType;
      }
    }

    return null;
  }

  /// 텍스트에서 Eidos 타입을 추출합니다
  static String? _extractTypeFromText(String text) {
    // Day Master와 Life Path Number 정보를 기반으로 Eidos Type 생성
    final dayMasterMatch = RegExp(
      r'Day Master.*?(\w+)\s*\(([^)]+)\)',
    ).firstMatch(text);
    final lifePathMatch = RegExp(
      r'Life Path Number.*?(\d+).*?the\s+([^.]+)',
    ).firstMatch(text);

    if (dayMasterMatch != null && lifePathMatch != null) {
      final element = dayMasterMatch.group(
        2,
      ); // Metal, Wood, Fire, Earth, Water
      final number = lifePathMatch.group(1);
      final archetype = lifePathMatch.group(2)?.trim();

      // Element와 Number를 기반으로 그룹 결정
      final group = _determineGroup(element, number);
      final role = _determineRole(archetype);

      if (group != null && role != null) {
        return 'The $role of $group';
      }
    }

    // 기존 그룹명들을 직접 찾기
    final groups = [
      'Green Mercenary',
      'Golden Sage',
      'Red Phoenix',
      'Blue Scholar',
      'Black Panther',
    ];
    for (final group in groups) {
      if (text.toLowerCase().contains(group.toLowerCase())) {
        return 'The Inspired Verdant Architect of $group'; // 기본 역할
      }
    }

    return null;
  }

  /// Element와 Number를 기반으로 그룹을 결정합니다
  static String? _determineGroup(String? element, String? number) {
    if (element == null || number == null) return null;

    final num = int.tryParse(number);
    if (num == null) return null;

    // Element와 Number 조합으로 그룹 결정
    switch (element.toLowerCase()) {
      case 'metal':
        return num % 2 == 0 ? 'Green Mercenary' : 'Golden Sage';
      case 'wood':
        return num <= 5 ? 'Green Mercenary' : 'Blue Scholar';
      case 'fire':
        return 'Red Phoenix';
      case 'earth':
        return num % 3 == 0 ? 'Golden Sage' : 'Black Panther';
      case 'water':
        return 'Blue Scholar';
      default:
        return 'Green Mercenary'; // 기본값
    }
  }

  /// Archetype에서 역할을 결정합니다
  static String? _determineRole(String? archetype) {
    if (archetype == null) return 'Inspired Verdant Architect';

    final arch = archetype.toLowerCase();
    if (arch.contains('powerhouse') || arch.contains('leader')) {
      return 'Resilient Verdant Architect';
    } else if (arch.contains('analyst') || arch.contains('thinker')) {
      return 'Wise Verdant Sage';
    } else if (arch.contains('creative') || arch.contains('artist')) {
      return 'Creative Verdant Artist';
    } else {
      return 'Inspired Verdant Architect';
    }
  }

  /// Raw data에서 Eidos 정보를 찾습니다
  static String? _searchInRawData(Map<String, dynamic> rawData) {
    // 재귀적으로 모든 필드를 검색
    for (final entry in rawData.entries) {
      final result = _searchInValue(entry.value);
      if (result != null) return result;
    }
    return null;
  }

  /// 값에서 재귀적으로 검색합니다
  static String? _searchInValue(dynamic value) {
    if (value is String) {
      final extracted = _extractTypeFromText(value);
      if (extracted != null) return extracted;
    } else if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final result = _searchInValue(entry.value);
        if (result != null) return result;
      }
    } else if (value is List) {
      for (final item in value) {
        final result = _searchInValue(item);
        if (result != null) return result;
      }
    }
    return null;
  }

  /// 타로카드 정보를 추출합니다
  static String? extractTarotCard(Map<String, dynamic> responseData) {
    // tarot_insight 섹션에서 카드명 추출
    final tarotInsight = responseData['tarot_insight'] as Map<String, dynamic>?;
    if (tarotInsight != null) {
      final cardTitle = tarotInsight['card_title']?.toString();
      if (cardTitle != null && cardTitle.isNotEmpty && cardTitle != 'N/A') {
        // "Card of Destiny: Strength" -> "Strength" 추출
        if (cardTitle.contains(':')) {
          return cardTitle.split(':').last.trim();
        }
        return cardTitle;
      }
    }

    // 다른 위치에서도 타로카드 정보 찾기
    final searches = ['tarot', 'card'];
    for (final search in searches) {
      final result = _searchForTarot(responseData, search);
      if (result != null) return result;
    }

    return null;
  }

  /// 타로카드 정보를 재귀적으로 찾습니다
  static String? _searchForTarot(dynamic data, String keyword) {
    if (data is Map<String, dynamic>) {
      for (final entry in data.entries) {
        if (entry.key.toLowerCase().contains(keyword)) {
          if (entry.value is String && entry.value.toString().isNotEmpty) {
            return entry.value.toString();
          }
        }
        final result = _searchForTarot(entry.value, keyword);
        if (result != null) return result;
      }
    } else if (data is List) {
      for (final item in data) {
        final result = _searchForTarot(item, keyword);
        if (result != null) return result;
      }
    }
    return null;
  }
}
