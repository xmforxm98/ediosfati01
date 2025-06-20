// This file contains the data models for the structured analysis report
// received from the server. Each class corresponds to a section of the
// rich report.

// Helper function to gracefully handle lists that might have been converted
// to maps for Firestore compatibility (to avoid nested arrays).
List<String> _dynamicToList(dynamic data) {
  if (data == null) return [];
  if (data is List) {
    return List<String>.from(data.map((e) => e.toString()));
  }
  // This handles the case where a list was converted to a map like {'0': 'a', '1': 'b'}
  if (data is Map) {
    // Sort keys as integers if possible, otherwise as strings
    final sortedKeys = data.keys.toList();
    try {
      sortedKeys.sort(
        (a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())),
      );
    } catch (e) {
      sortedKeys.sort((a, b) => a.toString().compareTo(b.toString()));
    }
    return sortedKeys.map((key) => data[key].toString()).toList();
  }
  if (data is String) {
    // Handle case where data might be a comma-separated string
    if (data.contains(',')) {
      return data.split(',').map((s) => s.trim()).toList();
    }
  }
  return [data.toString()];
}

class NarrativeReport {
  final EidosSummary eidosSummary;
  final InnateEidos innateEidos;
  final Journey journey;
  final TarotInsight tarotInsight;
  final RyusWisdom ryusWisdom;
  final PersonalityProfile personalityProfile;
  final RelationshipInsight relationshipInsight;
  final CareerProfile careerProfile;
  // For development and debugging, to inspect the raw data from the server.
  final Map<String, dynamic> rawDataForDev;
  final Map<String, dynamic> fiveElementsStrength;
  final Map<String, dynamic> nameOhaengEnglish;
  final String? eidosType;

  NarrativeReport({
    required this.eidosSummary,
    required this.innateEidos,
    required this.journey,
    required this.tarotInsight,
    required this.ryusWisdom,
    required this.personalityProfile,
    required this.relationshipInsight,
    required this.careerProfile,
    required this.rawDataForDev,
    required this.fiveElementsStrength,
    required this.nameOhaengEnglish,
    this.eidosType,
  });

  factory NarrativeReport.fromJson(Map<String, dynamic> json) {
    return NarrativeReport(
      eidosSummary: EidosSummary.fromJson(json['eidos_summary'] ?? {}),
      innateEidos: InnateEidos.fromJson(json['innate_eidos'] ?? {}),
      journey: Journey.fromJson(json['journey'] ?? {}),
      tarotInsight: TarotInsight.fromJson(json['tarot_insight'] ?? {}),
      ryusWisdom: RyusWisdom.fromJson(json['ryus_wisdom'] ?? {}),
      personalityProfile: PersonalityProfile.fromJson(
        json['personality_profile'] ?? {},
      ),
      relationshipInsight: RelationshipInsight.fromJson(
        json['relationship_insight'] ?? {},
      ),
      careerProfile: CareerProfile.fromJson(json['career_profile'] ?? {}),
      rawDataForDev: json['raw_data_for_dev'] ?? {},
      fiveElementsStrength: json['five_elements_strength'] ?? {},
      nameOhaengEnglish: json['name_ohaeng_english'] ?? {},
      eidosType: json['eidos_type'],
    );
  }
}

class EidosSummary {
  final String title;
  final String summaryTitle;
  final String summaryText;
  final String currentEnergyTitle;
  final String currentEnergyText;
  final String? eidosType;

  // 새로운 Enhanced API 필드들
  final String? personalizedExplanation;
  final List<String>? groupTraits;
  final List<String>? strengths;
  final List<String>? growthAreas;
  final String? lifeGuidance;
  final String? classificationReason;
  final String? groupId;

  EidosSummary({
    required this.title,
    required this.summaryTitle,
    required this.summaryText,
    required this.currentEnergyTitle,
    required this.currentEnergyText,
    this.eidosType,
    this.personalizedExplanation,
    this.groupTraits,
    this.strengths,
    this.growthAreas,
    this.lifeGuidance,
    this.classificationReason,
    this.groupId,
  });

  factory EidosSummary.fromJson(Map<String, dynamic> json) {
    print('🔧 EidosSummary.fromJson Debug:');
    print('   - Raw json keys: ${json.keys.toList()}');
    print('   - title: "${json['title']}"');
    print('   - summary_title: "${json['summary_title']}"');
    print('   - summaryTitle: "${json['summaryTitle']}"');
    print('   - summary_text: "${json['summary_text']}"');
    print('   - summaryText: "${json['summaryText']}"');
    print('   - description: "${json['description']}"');
    print('   - group_name: "${json['group_name']}"');
    print('   - eidos_type: "${json['eidos_type']}"');
    print('   - eidosType: "${json['eidosType']}"');

    // 실제 JSON 구조에 맞춰 필드 매핑
    final title = json['title'] ?? json['group_name'] ?? 'Eidos Summary';
    final summaryTitle = json['summary_title'] ??
        json['summaryTitle'] ??
        json['group_name'] ??
        'Your Eidos Type';
    final summaryText = json['summary_text'] ??
        json['summaryText'] ??
        json['description'] ??
        'Tap to see details';
    final eidosType = (json['eidos_type'] ?? json['eidosType'])?.toString();

    print('   - Final title: "$title"');
    print('   - Final summaryTitle: "$summaryTitle"');
    print('   - Final summaryText: "$summaryText"');
    print('   - Final eidosType: "$eidosType"');

    return EidosSummary(
      title: title,
      summaryTitle: summaryTitle,
      summaryText: summaryText,
      currentEnergyTitle: json['current_energy_title'] ??
          json['currentEnergyTitle'] ??
          'Current Energy',
      currentEnergyText: json['current_energy_text'] ??
          json['currentEnergyText'] ??
          json['description'] ??
          'N/A',
      eidosType: eidosType,
      // 새로운 Enhanced API 필드들
      personalizedExplanation: json['personalizedExplanation']?.toString(),
      groupTraits: json['groupTraits'] != null
          ? _dynamicToList(json['groupTraits'])
          : null,
      strengths:
          json['strengths'] != null ? _dynamicToList(json['strengths']) : null,
      growthAreas: json['growthAreas'] != null
          ? _dynamicToList(json['growthAreas'])
          : null,
      lifeGuidance: json['lifeGuidance']?.toString(),
      classificationReason: json['classificationReason']?.toString(),
      groupId: json['groupId']?.toString(),
    );
  }
}

class InnateEidos {
  final String title;
  final String coreEnergyTitle;
  final String coreEnergyText;
  final String talentTitle;
  final String talentText;
  final String desireTitle;
  final String desireText;

  InnateEidos({
    required this.title,
    required this.coreEnergyTitle,
    required this.coreEnergyText,
    required this.talentTitle,
    required this.talentText,
    required this.desireTitle,
    required this.desireText,
  });

  factory InnateEidos.fromJson(Map<String, dynamic> json) {
    return InnateEidos(
      title: json['title']?.toString() ?? 'N/A',
      coreEnergyTitle: json['core_energy_title']?.toString() ?? 'N/A',
      coreEnergyText: json['core_energy_text']?.toString() ?? 'N/A',
      talentTitle: json['talent_title']?.toString() ?? 'N/A',
      talentText: json['talent_text']?.toString() ?? 'N/A',
      desireTitle: json['desire_title']?.toString() ?? 'N/A',
      desireText: json['desire_text']?.toString() ?? 'N/A',
    );
  }
}

class Journey {
  final String title;
  final String daeunTitle;
  final String daeunText;
  final String currentYearTitle;
  final String currentYearText;

  Journey({
    required this.title,
    required this.daeunTitle,
    required this.daeunText,
    required this.currentYearTitle,
    required this.currentYearText,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      title: json['title']?.toString() ?? 'N/A',
      daeunTitle: json['daeun_title']?.toString() ?? 'N/A',
      daeunText: json['daeun_text']?.toString() ?? 'N/A',
      currentYearTitle: json['current_year_title']?.toString() ?? 'N/A',
      currentYearText: json['current_year_text']?.toString() ?? 'N/A',
    );
  }
}

class TarotInsight {
  final String title;
  final String cardTitle;
  final String cardMeaning;
  final String cardMessageTitle;
  final String cardMessageText;

  TarotInsight({
    required this.title,
    required this.cardTitle,
    required this.cardMeaning,
    required this.cardMessageTitle,
    required this.cardMessageText,
  });

  factory TarotInsight.fromJson(Map<String, dynamic> json) {
    return TarotInsight(
      title: json['title']?.toString() ?? 'N/A',
      cardTitle: json['card_title']?.toString() ?? 'N/A',
      cardMeaning: json['card_meaning']?.toString() ?? 'N/A',
      cardMessageTitle: json['card_message_title']?.toString() ?? 'N/A',
      cardMessageText: json['card_message_text']?.toString() ?? 'N/A',
    );
  }
}

class RyusWisdom {
  final String title;
  final String message;

  RyusWisdom({required this.title, required this.message});

  factory RyusWisdom.fromJson(Map<String, dynamic> json) {
    return RyusWisdom(
      title: json['title']?.toString() ?? 'N/A',
      message: json['message']?.toString() ?? 'N/A',
    );
  }
}

class PersonalityProfile {
  final String title;
  final String coreTraits;
  final String likes;
  final String dislikes;
  final String relationshipStyle;
  final String shadow;

  PersonalityProfile({
    required this.title,
    required this.coreTraits,
    required this.likes,
    required this.dislikes,
    required this.relationshipStyle,
    required this.shadow,
  });

  factory PersonalityProfile.fromJson(Map<String, dynamic> json) {
    // Safe parsing for new API structure
    String coreTraitsText = 'N/A';
    String likesText = 'N/A';
    String dislikesText = 'N/A';
    String relationshipStyleText = 'N/A';
    String shadowText = 'N/A';

    try {
      // Handle both old and new API structures
      final coreTraitsData = json['core_traits'];
      if (coreTraitsData is Map<String, dynamic>) {
        coreTraitsText = coreTraitsData['full_text']?.toString() ??
            coreTraitsData['text']?.toString() ??
            'N/A';
      } else if (coreTraitsData != null) {
        coreTraitsText = coreTraitsData.toString();
      }

      final likesData = json['likes'];
      if (likesData is List) {
        likesText = _dynamicToList(likesData).join(', ');
      } else if (likesData is Map<String, dynamic>) {
        likesText = likesData['full_text']?.toString() ??
            likesData['text']?.toString() ??
            'N/A';
      } else if (likesData != null) {
        likesText = likesData.toString();
      }

      final dislikesData = json['dislikes'];
      if (dislikesData is List) {
        dislikesText = _dynamicToList(dislikesData).join(', ');
      } else if (dislikesData is Map<String, dynamic>) {
        dislikesText = dislikesData['full_text']?.toString() ??
            dislikesData['text']?.toString() ??
            'N/A';
      } else if (dislikesData != null) {
        dislikesText = dislikesData.toString();
      }

      final relationshipStyleData = json['relationship_style'];
      if (relationshipStyleData is Map<String, dynamic>) {
        relationshipStyleText =
            relationshipStyleData['full_text']?.toString() ??
                relationshipStyleData['text']?.toString() ??
                'N/A';
      } else if (relationshipStyleData != null) {
        relationshipStyleText = relationshipStyleData.toString();
      }

      final shadowData = json['shadow'];
      if (shadowData is Map<String, dynamic>) {
        shadowText = shadowData['full_text']?.toString() ??
            shadowData['text']?.toString() ??
            'N/A';
      } else if (shadowData != null) {
        shadowText = shadowData.toString();
      }
    } catch (e) {
      print('Error parsing PersonalityProfile: $e');
    }

    return PersonalityProfile(
      title: json['title']?.toString() ?? 'Personality Profile',
      coreTraits: coreTraitsText,
      likes: likesText,
      dislikes: dislikesText,
      relationshipStyle: relationshipStyleText,
      shadow: shadowText,
    );
  }
}

class RelationshipInsight {
  final String title;
  final String loveStyle;
  final String idealPartner;
  final String relationshipAdvice;

  RelationshipInsight({
    required this.title,
    required this.loveStyle,
    required this.idealPartner,
    required this.relationshipAdvice,
  });

  factory RelationshipInsight.fromJson(Map<String, dynamic> json) {
    // Safely extract text from the new API structure
    String loveStyleText = 'N/A';
    String idealPartnerText = 'N/A';
    String relationshipAdviceText = 'N/A';

    try {
      // Handle new API structure where each field is an object with full_text
      final loveStyleData = json['love_style'];
      if (loveStyleData is Map<String, dynamic>) {
        loveStyleText = loveStyleData['full_text']?.toString() ??
            loveStyleData['text']?.toString() ??
            'N/A';
      } else if (loveStyleData is String) {
        loveStyleText = loveStyleData;
      }

      final idealPartnerData = json['ideal_partner'];
      if (idealPartnerData is Map<String, dynamic>) {
        idealPartnerText = idealPartnerData['full_text']?.toString() ??
            idealPartnerData['text']?.toString() ??
            'N/A';
      } else if (idealPartnerData is String) {
        idealPartnerText = idealPartnerData;
      }

      final relationshipAdviceData = json['relationship_advice'];
      if (relationshipAdviceData is Map<String, dynamic>) {
        relationshipAdviceText =
            relationshipAdviceData['full_text']?.toString() ??
                relationshipAdviceData['text']?.toString() ??
                'N/A';
      } else if (relationshipAdviceData is String) {
        relationshipAdviceText = relationshipAdviceData;
      }
    } catch (e) {
      print('Error parsing RelationshipInsight: $e');
    }

    return RelationshipInsight(
      title: json['title']?.toString() ?? 'Relationship Insight',
      loveStyle: loveStyleText,
      idealPartner: idealPartnerText,
      relationshipAdvice: relationshipAdviceText,
    );
  }
}

class CareerProfile {
  final String title;
  final String aptitude;
  final String workStyle;
  final String successStrategy;

  CareerProfile({
    required this.title,
    required this.aptitude,
    required this.workStyle,
    required this.successStrategy,
  });

  factory CareerProfile.fromJson(Map<String, dynamic> json) {
    // Safe parsing for aptitude field
    String aptitudeText = 'N/A';

    try {
      final aptitudeData = json['aptitude'];
      if (aptitudeData is List) {
        aptitudeText = _dynamicToList(aptitudeData).join(', ');
      } else if (aptitudeData is Map<String, dynamic>) {
        aptitudeText = aptitudeData['full_text']?.toString() ??
            aptitudeData['text']?.toString() ??
            'N/A';
      } else if (aptitudeData != null) {
        aptitudeText = aptitudeData.toString();
      }
    } catch (e) {
      print('Error parsing CareerProfile aptitude: $e');
    }

    return CareerProfile(
      title: json['title']?.toString() ?? 'Career Profile',
      aptitude: aptitudeText,
      workStyle: json['work_style']?.toString() ?? 'N/A',
      successStrategy: json['success_strategy']?.toString() ?? 'N/A',
    );
  }
}
