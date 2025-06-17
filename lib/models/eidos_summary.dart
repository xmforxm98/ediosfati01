class EidosSummary {
  final String title;
  final String summaryTitle;
  final String summaryText;
  final String personalizedExplanation;
  final List<String> groupTraits;
  final List<String> strengths;
  final List<String> growthAreas;
  final String lifeGuidance;
  final String classificationReason;
  final String currentEnergyTitle;
  final String currentEnergyText;
  final String eidosType;
  final String groupId;
  String cardImageUrl;

  EidosSummary({
    required this.title,
    required this.summaryTitle,
    required this.summaryText,
    required this.personalizedExplanation,
    required this.groupTraits,
    required this.strengths,
    required this.growthAreas,
    required this.lifeGuidance,
    required this.classificationReason,
    required this.currentEnergyTitle,
    required this.currentEnergyText,
    required this.eidosType,
    required this.groupId,
    required this.cardImageUrl,
  });

  factory EidosSummary.fromJson(Map<String, dynamic> json) {
    return EidosSummary(
      title: json['title'] ?? '',
      summaryTitle: json['summaryTitle'] ?? '',
      summaryText: json['summaryText'] ?? '',
      personalizedExplanation: json['personalizedExplanation'] ?? '',
      groupTraits: List<String>.from(json['groupTraits'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      growthAreas: List<String>.from(json['growthAreas'] ?? []),
      lifeGuidance: json['lifeGuidance'] ?? '',
      classificationReason: json['classificationReason'] ?? '',
      currentEnergyTitle: json['currentEnergyTitle'] ?? '',
      currentEnergyText: json['currentEnergyText'] ?? '',
      eidosType: json['eidosType'] ?? '',
      groupId: json['groupId'] ?? '',
      cardImageUrl: json['card_image_url'] ?? '',
    );
  }
}
