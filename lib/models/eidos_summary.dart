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

  factory EidosSummary.fromJson(Map<String, dynamic> json) {
    print('🔧 EidosSummary.fromJson Debug:');
    print('   - Raw json keys: ${json.keys.toList()}');

    // Map new API response structure to original fields
    final intro = json['personalized_introduction'] ?? {};
    final classificationReasoning = json['classification_reasoning'] ?? {};
    final coreIdentity = json['core_identity_section'] ?? {};
    final traits = json['traits_section'] ?? {};
    final strengthsSection = json['strengths_section'] ?? {};
    final growthSection = json['growth_areas_section'] ?? {};
    final lifeGuidanceSection = json['life_guidance_section'] ?? {};

    print('   - title: "${json['title']}"');
    print('   - summary_title: "${json['summary_title']}"');
    print('   - summaryTitle: "${json['summaryTitle']}"');
    print('   - summary_text: "${json['summary_text']}"');
    print('   - summaryText: "${json['summaryText']}"');
    print('   - description: "${json['description']}"');
    print('   - group_name: "${json['group_name']}"');
    print('   - eidos_type: "${json['eidos_type']}"');
    print('   - eidosType: "${json['eidosType']}"');

    // 개인의 실제 타입 추출 (personalized_introduction에서)
    String individualType = '';
    final introOpening = intro['opening']?.toString() ?? '';

    // "As a The Tempered Sword" 형태에서 개인 타입 추출
    final asAPattern = RegExp(r'As a (The [^,\.]+)');
    final match = asAPattern.firstMatch(introOpening);
    if (match != null) {
      individualType = match.group(1)?.trim() ?? '';
      print('🎯 Extracted individual type from intro: "$individualType"');
    }

    // 개인 타입이 없으면 그룹명 사용
    final eidosTypeValue = individualType.isNotEmpty
        ? individualType
        : (json['eidos_type'] ?? json['eidos_group_name'] ?? '');

    // Determine title and summaryTitle
    final finalTitle = json['title'] ??
        json['summary_title'] ??
        json['summaryTitle'] ??
        intro['title'] ??
        json['eidos_group_name'] ??
        'Your Unique Essence';

    final finalSummaryTitle = json['eidos_group_name'] ??
        json['group_name'] ??
        json['summary_title'] ??
        json['summaryTitle'] ??
        'Unknown Group';

    final finalSummaryText = json['description'] ??
        json['summary_text'] ??
        json['summaryText'] ??
        intro['opening'] ??
        'No summary available.';

    print('   - Final title: "$finalTitle"');
    print('   - Final summaryTitle: "$finalSummaryTitle"');
    print('   - Final summaryText: "$finalSummaryText"');
    print('   - Final eidosType: "$eidosTypeValue"');

    print('🔧 EidosSummary.fromJson:');
    print('   - intro opening: $introOpening');
    print('   - extracted individual type: $individualType');
    print('   - json[eidos_type]: ${json['eidos_type']}');
    print('   - json[eidos_group_name]: ${json['eidos_group_name']}');
    print('   - Final eidosType: $eidosTypeValue');

    return EidosSummary(
      title: finalTitle,
      summaryTitle: finalSummaryTitle,
      summaryText: finalSummaryText,
      personalizedExplanation:
          classificationReasoning['text'] ?? intro['connection'] ?? '',
      groupTraits: _safeListFromDynamic(traits['points']),
      strengths: _safeListFromDynamic(strengthsSection['points']),
      growthAreas: _safeListFromDynamic(growthSection['points']),
      lifeGuidance: lifeGuidanceSection['text'] ?? '',
      classificationReason: classificationReasoning['title'] ?? '',
      currentEnergyTitle: coreIdentity['title'] ?? 'Core Identity',
      currentEnergyText: coreIdentity['text'] ?? '',
      eidosType: eidosTypeValue, // 개인 타입 우선 사용
      groupId: json['eidos_group_id'] ?? '',
      cardImageUrl: '',
    );
  }
}
