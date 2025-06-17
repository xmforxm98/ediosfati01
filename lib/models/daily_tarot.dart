class DailyTarot {
  final String cardId;
  final String cardNameDisplay;
  final String cardImageUrl;
  final DailyTarotMessage message;

  DailyTarot({
    required this.cardId,
    required this.cardNameDisplay,
    required this.cardImageUrl,
    required this.message,
  });

  factory DailyTarot.fromJson(Map<String, dynamic> json) {
    final dailyTarotDraw = json['daily_tarot_draw'];
    if (dailyTarotDraw == null) {
      throw const FormatException('Missing "daily_tarot_draw" in JSON');
    }

    return DailyTarot(
      cardId: dailyTarotDraw['card_id'] ?? 'Unknown',
      cardNameDisplay: dailyTarotDraw['card_name_display'] ?? 'Unknown Card',
      cardImageUrl: dailyTarotDraw['card_image_url'] ?? '',
      message: DailyTarotMessage.fromJson(dailyTarotDraw['message'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'card_name_display': cardNameDisplay,
      'card_image_url': cardImageUrl,
      'message': message.toJson(),
    };
  }
}

class DailyTarotMessage {
  final String title;
  final String content;
  final List<DailyTarotSection> sections;
  final String aphorism;
  final List<String> hashtags;
  final String illustrationCue;

  DailyTarotMessage({
    required this.title,
    required this.content,
    required this.sections,
    required this.aphorism,
    required this.hashtags,
    required this.illustrationCue,
  });

  factory DailyTarotMessage.fromJson(Map<String, dynamic> json) {
    var sectionsFromJson = json['sections'] as List<dynamic>?;
    List<DailyTarotSection> sectionList =
        sectionsFromJson?.map((i) => DailyTarotSection.fromJson(i)).toList() ??
            [];

    var hashtagsFromJson = json['hashtags'] as List<dynamic>?;
    List<String> hashtagList =
        hashtagsFromJson?.map((i) => i.toString()).toList() ?? [];

    return DailyTarotMessage(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sections: sectionList,
      aphorism: json['aphorism'] ?? '',
      hashtags: hashtagList,
      illustrationCue: json['illustration_cue'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'sections': sections.map((s) => s.toJson()).toList(),
      'aphorism': aphorism,
      'hashtags': hashtags,
      'illustration_cue': illustrationCue,
    };
  }
}

class DailyTarotSection {
  final String title;
  final String content;

  DailyTarotSection({required this.title, required this.content});

  factory DailyTarotSection.fromJson(Map<String, dynamic> json) {
    return DailyTarotSection(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}
