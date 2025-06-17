class InnateEidos {
  final String coreEnergyText;
  final String talentText;
  final String desireText;

  InnateEidos({
    required this.coreEnergyText,
    required this.talentText,
    required this.desireText,
  });

  factory InnateEidos.fromJson(Map<String, dynamic> json) {
    return InnateEidos(
      coreEnergyText: json['core_energy_text'] ?? '',
      talentText: json['talent_text'] ?? '',
      desireText: json['desire_text'] ?? '',
    );
  }
}

class PersonalityProfile {
  final String coreTraits;
  final String likes;
  final String dislikes;
  final String relationshipStyle;
  final String shadow;

  PersonalityProfile({
    required this.coreTraits,
    required this.likes,
    required this.dislikes,
    required this.relationshipStyle,
    required this.shadow,
  });

  factory PersonalityProfile.fromJson(Map<String, dynamic> json) {
    return PersonalityProfile(
      coreTraits: json['core_traits'] ?? '',
      likes: json['likes'] ?? '',
      dislikes: json['dislikes'] ?? '',
      relationshipStyle: json['relationship_style'] ?? '',
      shadow: json['shadow'] ?? '',
    );
  }
}

class RelationshipInsight {
  final String loveStyle;
  final String idealPartner;
  final String relationshipAdvice;

  RelationshipInsight({
    required this.loveStyle,
    required this.idealPartner,
    required this.relationshipAdvice,
  });

  factory RelationshipInsight.fromJson(Map<String, dynamic> json) {
    return RelationshipInsight(
      loveStyle: json['love_style'] ?? '',
      idealPartner: json['ideal_partner'] ?? '',
      relationshipAdvice: json['relationship_advice'] ?? '',
    );
  }
}

class CareerProfile {
  final String aptitude;
  final String workStyle;
  final String successStrategy;

  CareerProfile({
    required this.aptitude,
    required this.workStyle,
    required this.successStrategy,
  });

  factory CareerProfile.fromJson(Map<String, dynamic> json) {
    return CareerProfile(
      aptitude: json['aptitude'] ?? '',
      workStyle: json['work_style'] ?? '',
      successStrategy: json['success_strategy'] ?? '',
    );
  }
}

class Journey {
  final String daeunText;
  final String currentYearText;

  Journey({required this.daeunText, required this.currentYearText});

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      daeunText: json['daeun_text'] ?? '',
      currentYearText: json['current_year_text'] ?? '',
    );
  }
}

class TarotInsight {
  final String cardTitle;
  final String cardMeaning;
  final String cardMessageText;

  TarotInsight({
    required this.cardTitle,
    required this.cardMeaning,
    required this.cardMessageText,
  });

  factory TarotInsight.fromJson(Map<String, dynamic> json) {
    return TarotInsight(
      cardTitle: json['card_title'] ?? '',
      cardMeaning: json['card_meaning'] ?? '',
      cardMessageText: json['card_message_text'] ?? '',
    );
  }
}

class FiveElementsStrength {
  final Map<String, int> strengths;

  FiveElementsStrength({required this.strengths});

  factory FiveElementsStrength.fromJson(Map<String, dynamic> json) {
    return FiveElementsStrength(
      strengths: Map<String, int>.from(
          json.map((key, value) => MapEntry(key, value as int))),
    );
  }
}

class DetailedReport {
  final InnateEidos? innateEidos;
  final PersonalityProfile? personalityProfile;
  final RelationshipInsight? relationshipInsight;
  final CareerProfile? careerProfile;
  final Journey? journey;
  final TarotInsight? tarotInsight;
  final FiveElementsStrength? fiveElementsStrength;

  DetailedReport({
    this.innateEidos,
    this.personalityProfile,
    this.relationshipInsight,
    this.careerProfile,
    this.journey,
    this.tarotInsight,
    this.fiveElementsStrength,
  });

  factory DetailedReport.fromJson(Map<String, dynamic> json) {
    return DetailedReport(
      innateEidos: json['innate_eidos'] != null
          ? InnateEidos.fromJson(json['innate_eidos'])
          : null,
      personalityProfile: json['personality_profile'] != null
          ? PersonalityProfile.fromJson(json['personality_profile'])
          : null,
      relationshipInsight: json['relationship_insight'] != null
          ? RelationshipInsight.fromJson(json['relationship_insight'])
          : null,
      careerProfile: json['career_profile'] != null
          ? CareerProfile.fromJson(json['career_profile'])
          : null,
      journey:
          json['journey'] != null ? Journey.fromJson(json['journey']) : null,
      tarotInsight: json['tarot_insight'] != null
          ? TarotInsight.fromJson(json['tarot_insight'])
          : null,
      fiveElementsStrength: json['five_elements_strength'] != null
          ? FiveElementsStrength.fromJson(json['five_elements_strength'])
          : null,
    );
  }
}
