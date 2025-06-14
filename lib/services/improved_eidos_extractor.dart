class ImprovedEidosExtractor {
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
      final summaryText = eidosSummary['summary_text']?.toString() ?? '';
      final extractedType = _extractTypeFromSummary(summaryText);
      if (extractedType != null) {
        return extractedType;
      }
    }

    // 3. innate_eidos 섹션에서 추출 시도
    final innateEidos = responseData['innate_eidos'] as Map<String, dynamic>?;
    if (innateEidos != null) {
      final coreEnergyText = innateEidos['core_energy_text']?.toString() ?? '';
      final extractedType = _extractTypeFromCoreEnergy(coreEnergyText);
      if (extractedType != null) {
        return extractedType;
      }
    }

    return null;
  }

  /// Summary text에서 Eidos 타입을 추출합니다
  /// 패턴: "you are a A Sword or Axe with the soul of a The Powerhouse."
  static String? _extractTypeFromSummary(String text) {
    final summaryMatch = RegExp(
      r'you are a\s+([^.]+?)\s+with the soul of a\s+([^.]+?)\.',
    ).firstMatch(text);
    if (summaryMatch != null) {
      final type1 = summaryMatch.group(1)?.trim(); // A Sword or Axe
      final type2 = summaryMatch.group(2)?.trim(); // The Powerhouse

      // Debug: print('🔍 Summary - Type1: $type1, Type2: $type2');

      // Type1에서 element 유추
      final element = _getElementFromType(type1);
      // Type2에서 number 유추
      final number = _getNumberFromArchetype(type2);

      if (element != null && number != null) {
        final group = _determineGroup(element, number);
        final role = _determineRole(type2);

        // Debug: print('🔍 Summary - Element: $element, Number: $number, Group: $group, Role: $role');

        if (group != null && role != null) {
          return 'The $role of $group';
        }
      }
    }
    return null;
  }

  /// Core energy text에서 Eidos 타입을 추출합니다
  /// 패턴: "is 庚 (Metal), resembling A Sword or Axe" + "Life Path Number, 8, guides this energy along the path of the The Powerhouse."
  static String? _extractTypeFromCoreEnergy(String text) {
    // Day Master 패턴: "is 庚 (Metal), resembling A Sword or Axe"
    final dayMasterMatch = RegExp(r'is\s+\S+\s*\(([^)]+)\)').firstMatch(text);

    // Life Path Number 패턴: "Life Path Number, 8, guides this energy along the path of the The Powerhouse"
    final lifePathMatch = RegExp(
      r'Life Path Number,\s*(\d+),.*?path of the\s+(.+?)\.',
    ).firstMatch(text);

    if (dayMasterMatch != null && lifePathMatch != null) {
      final element = dayMasterMatch.group(
        1,
      ); // Metal, Wood, Fire, Earth, Water
      final number = lifePathMatch.group(1);
      final archetype = lifePathMatch.group(2)?.trim();

      // Debug: print('🔍 CoreEnergy - Element: $element, Number: $number, Archetype: $archetype');

      final group = _determineGroup(element, number);
      final role = _determineRole(archetype);

      // Debug: print('🔍 CoreEnergy - Group: $group, Role: $role');

      if (group != null && role != null) {
        return 'The $role of $group';
      }
    }

    return null;
  }

  /// Type description에서 element를 유추합니다
  static String? _getElementFromType(String? type) {
    if (type == null) return null;

    final typeLower = type.toLowerCase();
    if (typeLower.contains('sword') ||
        typeLower.contains('axe') ||
        typeLower.contains('metal')) {
      return 'Metal';
    } else if (typeLower.contains('wood') ||
        typeLower.contains('tree') ||
        typeLower.contains('plant')) {
      return 'Wood';
    } else if (typeLower.contains('fire') ||
        typeLower.contains('flame') ||
        typeLower.contains('burn')) {
      return 'Fire';
    } else if (typeLower.contains('earth') ||
        typeLower.contains('mountain') ||
        typeLower.contains('stone')) {
      return 'Earth';
    } else if (typeLower.contains('water') ||
        typeLower.contains('ocean') ||
        typeLower.contains('river')) {
      return 'Water';
    }
    return null;
  }

  /// Archetype에서 life path number를 유추합니다
  static String? _getNumberFromArchetype(String? archetype) {
    if (archetype == null) return null;

    final archLower = archetype.toLowerCase();
    if (archLower.contains('powerhouse') || archLower.contains('executive')) {
      return '8';
    } else if (archLower.contains('analyst') || archLower.contains('seeker')) {
      return '7';
    } else if (archLower.contains('leader') || archLower.contains('pioneer')) {
      return '1';
    } else if (archLower.contains('cooperator') ||
        archLower.contains('peacemaker')) {
      return '2';
    } else if (archLower.contains('creative') ||
        archLower.contains('communicator')) {
      return '3';
    } else if (archLower.contains('builder') ||
        archLower.contains('organizer')) {
      return '4';
    } else if (archLower.contains('freedom') ||
        archLower.contains('adventurer')) {
      return '5';
    } else if (archLower.contains('nurturer') ||
        archLower.contains('caregiver')) {
      return '6';
    } else if (archLower.contains('humanitarian') ||
        archLower.contains('global')) {
      return '9';
    }
    return '1'; // 기본값
  }

  /// Element와 Number를 기반으로 그룹을 결정합니다
  static String? _determineGroup(String? element, String? number) {
    if (element == null || number == null) return null;

    final num = int.tryParse(number);
    if (num == null) return null;

    // 개선된 그룹 결정 로직
    switch (element.toLowerCase()) {
      case 'metal':
        if (num == 8) return 'Golden Sage'; // Metal + Powerhouse = Golden Sage
        if (num == 7) return 'Blue Scholar'; // Metal + Analyst = Blue Scholar
        return num % 2 == 0 ? 'Green Mercenary' : 'Golden Sage';
      case 'wood':
        if (num == 1)
          return 'Green Mercenary'; // Wood + Leader = Green Mercenary
        return num <= 5 ? 'Green Mercenary' : 'Blue Scholar';
      case 'fire':
        return 'Red Phoenix'; // Fire always = Red Phoenix
      case 'earth':
        if (num == 8)
          return 'Black Panther'; // Earth + Powerhouse = Black Panther
        return num % 3 == 0 ? 'Golden Sage' : 'Black Panther';
      case 'water':
        return 'Blue Scholar'; // Water always = Blue Scholar
      default:
        return 'Green Mercenary'; // 기본값
    }
  }

  /// Archetype에서 역할을 결정합니다
  static String? _determineRole(String? archetype) {
    if (archetype == null) return 'Inspired Verdant Architect';

    final arch = archetype.toLowerCase();
    if (arch.contains('powerhouse') ||
        arch.contains('executive') ||
        arch.contains('leader')) {
      return 'Resilient Verdant Architect';
    } else if (arch.contains('analyst') ||
        arch.contains('seeker') ||
        arch.contains('thinker')) {
      return 'Wise Verdant Sage';
    } else if (arch.contains('creative') ||
        arch.contains('communicator') ||
        arch.contains('artist')) {
      return 'Creative Verdant Artist';
    } else if (arch.contains('nurturer') ||
        arch.contains('caregiver') ||
        arch.contains('healer')) {
      return 'Compassionate Verdant Healer';
    } else if (arch.contains('humanitarian') ||
        arch.contains('global') ||
        arch.contains('visionary')) {
      return 'Visionary Verdant Oracle';
    } else {
      return 'Inspired Verdant Architect';
    }
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
    return null;
  }
}
