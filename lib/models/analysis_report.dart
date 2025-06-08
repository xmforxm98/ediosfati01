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
    );
  }
}

class EidosSummary {
  final String title;
  final String summaryTitle;
  final String summaryText;
  final String currentEnergyTitle;
  final String currentEnergyText;

  EidosSummary({
    required this.title,
    required this.summaryTitle,
    required this.summaryText,
    required this.currentEnergyTitle,
    required this.currentEnergyText,
  });

  factory EidosSummary.fromJson(Map<String, dynamic> json) {
    return EidosSummary(
      title: json['title'] ?? 'N/A',
      summaryTitle: json['summary_title'] ?? 'N/A',
      summaryText: json['summary_text'] ?? 'N/A',
      currentEnergyTitle: json['current_energy_title'] ?? 'N/A',
      currentEnergyText: json['current_energy_text'] ?? 'N/A',
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
      title: json['title'] ?? 'N/A',
      coreEnergyTitle: json['core_energy_title'] ?? 'N/A',
      coreEnergyText: json['core_energy_text'] ?? 'N/A',
      talentTitle: json['talent_title'] ?? 'N/A',
      talentText: json['talent_text'] ?? 'N/A',
      desireTitle: json['desire_title'] ?? 'N/A',
      desireText: json['desire_text'] ?? 'N/A',
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
      title: json['title'] ?? 'N/A',
      daeunTitle: json['daeun_title'] ?? 'N/A',
      daeunText: json['daeun_text'] ?? 'N/A',
      currentYearTitle: json['current_year_title'] ?? 'N/A',
      currentYearText: json['current_year_text'] ?? 'N/A',
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
      title: json['title'] ?? 'N/A',
      cardTitle: json['card_title'] ?? 'N/A',
      cardMeaning: json['card_meaning'] ?? 'N/A',
      cardMessageTitle: json['card_message_title'] ?? 'N/A',
      cardMessageText: json['card_message_text'] ?? 'N/A',
    );
  }
}

class RyusWisdom {
  final String title;
  final String message;

  RyusWisdom({required this.title, required this.message});

  factory RyusWisdom.fromJson(Map<String, dynamic> json) {
    return RyusWisdom(
      title: json['title'] ?? 'N/A',
      message: json['message'] ?? 'N/A',
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
    // Assuming fields like 'likes' or 'dislikes' might be lists from the API
    return PersonalityProfile(
      title: json['title'] ?? 'N/A',
      coreTraits: json['core_traits'] ?? 'N/A',
      likes: _dynamicToList(json['likes']).join(', '),
      dislikes: _dynamicToList(json['dislikes']).join(', '),
      relationshipStyle: json['relationship_style'] ?? 'N/A',
      shadow: json['shadow'] ?? 'N/A',
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
    return RelationshipInsight(
      title: json['title'] ?? 'N/A',
      loveStyle: json['love_style'] ?? 'N/A',
      idealPartner: json['ideal_partner'] ?? 'N/A',
      relationshipAdvice: json['relationship_advice'] ?? 'N/A',
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
    return CareerProfile(
      title: json['title'] ?? 'N/A',
      aptitude: _dynamicToList(json['aptitude']).join(', '),
      workStyle: json['work_style'] ?? 'N/A',
      successStrategy: json['success_strategy'] ?? 'N/A',
    );
  }
}
