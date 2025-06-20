import 'eidos_summary.dart';

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

class Section {
  final String title;
  final String text;
  final List<String> points;
  final String? opening;
  final String? connection;

  Section({
    required this.title,
    required this.text,
    required this.points,
    this.opening,
    this.connection,
  });

  /// Safely converts dynamic data to List<String>
  static List<String> _safeListFromDynamic(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    if (data is String && data.isNotEmpty) {
      // Split by newlines or bullet points if it's a string
      return data
          .split(RegExp(r'\n|•'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  factory Section.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return Section(title: '', text: '', points: []);
    }
    return Section(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      points: _safeListFromDynamic(json['points']),
      opening: json['opening'],
      connection: json['connection'],
    );
  }
}

class DetailedReport {
  final EidosSummary eidosSummary;
  final Section personalizedIntroduction;
  final Section coreIdentitySection;
  final Section strengthsSection;
  final Section growthAreasSection;
  final Section lifeGuidanceSection;
  final Section traitsSection;
  final String classificationReasoning;

  DetailedReport({
    required this.eidosSummary,
    required this.personalizedIntroduction,
    required this.coreIdentitySection,
    required this.strengthsSection,
    required this.growthAreasSection,
    required this.lifeGuidanceSection,
    required this.traitsSection,
    required this.classificationReasoning,
  });

  factory DetailedReport.fromJson(Map<String, dynamic> json) {
    // Handle classification_reasoning which is an object, not a string
    String classificationReasoningText = '';
    final classificationReasoning = json['classification_reasoning'];
    if (classificationReasoning is Map<String, dynamic>) {
      classificationReasoningText = classificationReasoning['text'] ?? '';
    } else if (classificationReasoning is String) {
      classificationReasoningText = classificationReasoning;
    }

    return DetailedReport(
      eidosSummary: EidosSummary.fromJson(json),
      personalizedIntroduction:
          Section.fromJson(json['personalized_introduction'] ?? {}),
      coreIdentitySection:
          Section.fromJson(json['core_identity_section'] ?? {}),
      strengthsSection: Section.fromJson(json['strengths_section'] ?? {}),
      growthAreasSection: Section.fromJson(json['growth_areas_section'] ?? {}),
      lifeGuidanceSection:
          Section.fromJson(json['life_guidance_section'] ?? {}),
      traitsSection: Section.fromJson(json['traits_section'] ?? {}),
      classificationReasoning: classificationReasoningText,
    );
  }
}
