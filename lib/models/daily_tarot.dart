class DailyTarot {
  final String cardId;
  final String cardNameDisplay;
  final String cardImageUrl;
  final String cardMeaning;
  final DailyTarotMessage message;
  final String userName;
  final String fortuneMessage;
  final String themeKeyword;
  final String luckyColor;
  final String eidosType;
  final String eidosGroup;

  DailyTarot({
    required this.cardId,
    required this.cardNameDisplay,
    required this.cardImageUrl,
    required this.cardMeaning,
    required this.message,
    required this.userName,
    required this.fortuneMessage,
    required this.themeKeyword,
    required this.luckyColor,
    required this.eidosType,
    required this.eidosGroup,
  });

  factory DailyTarot.fromJson(Map<String, dynamic> json) {
    final dailyTarotDraw = json['daily_tarot_draw'];
    if (dailyTarotDraw == null) {
      throw const FormatException('Missing "daily_tarot_draw" in JSON');
    }

    // Safely parse all string fields
    String cardId = '';
    String cardNameDisplay = '';
    String cardImageUrl = '';
    String cardMeaning = '';
    String userName = '';
    String fortuneMessage = '';
    String themeKeyword = '';
    String luckyColor = '';
    String eidosType = '';
    String eidosGroup = '';

    try {
      cardId = dailyTarotDraw['card_id']?.toString() ?? 'Unknown';
      cardNameDisplay =
          dailyTarotDraw['card_name_display']?.toString() ?? 'Unknown Card';
      cardImageUrl = dailyTarotDraw['card_image_url']?.toString() ?? '';
      cardMeaning = json['card_meaning']?.toString() ?? '';
      userName = json['user_name']?.toString() ?? 'Seeker';
      fortuneMessage = json['fortune_message']?.toString() ?? '';
      themeKeyword = json['theme_keyword']?.toString() ?? '';
      luckyColor = json['lucky_color']?.toString() ?? '';
      eidosType = json['eidos_type']?.toString() ?? '';
      eidosGroup = json['eidos_group']?.toString() ?? '';
    } catch (e) {
      print('Error parsing DailyTarot string fields: $e');
    }

    // Safely parse message
    DailyTarotMessage message;
    try {
      message = DailyTarotMessage.fromJson(dailyTarotDraw['message'] ?? {});
    } catch (e) {
      print('Error parsing DailyTarotMessage: $e');
      // Create default message if parsing fails
      message = DailyTarotMessage(
        title: 'Daily Guidance',
        content: 'Your tarot guidance for today.',
        sections: [],
        aphorism: '',
        hashtags: [],
        illustrationCue: '',
      );
    }

    return DailyTarot(
      cardId: cardId,
      cardNameDisplay: cardNameDisplay,
      cardImageUrl: cardImageUrl,
      cardMeaning: cardMeaning,
      message: message,
      userName: userName,
      fortuneMessage: fortuneMessage,
      themeKeyword: themeKeyword,
      luckyColor: luckyColor,
      eidosType: eidosType,
      eidosGroup: eidosGroup,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_tarot_draw': {
        'card_id': cardId,
        'card_name_display': cardNameDisplay,
        'card_image_url': cardImageUrl,
        'message': message.toJson(),
      },
      'card_meaning': cardMeaning,
      'user_name': userName,
      'fortune_message': fortuneMessage,
      'theme_keyword': themeKeyword,
      'lucky_color': luckyColor,
      'eidos_type': eidosType,
      'eidos_group': eidosGroup,
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
    List<DailyTarotSection> sectionList = [];

    // Handle sections - API returns Map not List
    var sectionsFromJson = json['sections'];
    if (sectionsFromJson != null) {
      try {
        if (sectionsFromJson is Map<String, dynamic>) {
          // Convert Map to List of sections
          sectionsFromJson.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              sectionList.add(DailyTarotSection.fromJson(value, key));
            }
          });
        } else if (sectionsFromJson is List<dynamic>) {
          // Handle as List (fallback)
          sectionList = sectionsFromJson
              .map((i) => DailyTarotSection.fromJson(i as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print('Error parsing sections in DailyTarotMessage: $e');
      }
    }

    var hashtagsFromJson = json['hashtags'];
    List<String> hashtagList = [];

    // Safely handle hashtags
    if (hashtagsFromJson != null) {
      try {
        if (hashtagsFromJson is List) {
          hashtagList = hashtagsFromJson.map((i) => i.toString()).toList();
        }
      } catch (e) {
        print('Error parsing hashtags: $e');
      }
    }

    // Safely handle string fields
    String title = '';
    String content = '';
    String aphorism = '';
    String illustrationCue = '';

    try {
      title = json['title']?.toString() ?? '';
      content = json['content']?.toString() ?? '';
      aphorism = json['aphorism']?.toString() ?? '';
      illustrationCue = json['illustration_cue']?.toString() ?? '';
    } catch (e) {
      print('Error parsing DailyTarotMessage string fields: $e');
    }

    return DailyTarotMessage(
      title: title,
      content: content,
      sections: sectionList,
      aphorism: aphorism,
      hashtags: hashtagList,
      illustrationCue: illustrationCue,
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
  final List<String> points;
  final String fullText;
  final String sectionKey;

  DailyTarotSection({
    required this.title,
    required this.content,
    required this.points,
    required this.fullText,
    required this.sectionKey,
  });

  factory DailyTarotSection.fromJson(Map<String, dynamic> json,
      [String key = '']) {
    var pointsFromJson = json['points'];
    List<String> pointsList = [];

    // Safely handle points regardless of type
    if (pointsFromJson != null) {
      if (pointsFromJson is List) {
        pointsList = pointsFromJson.map((i) => i.toString()).toList();
      } else if (pointsFromJson is String) {
        pointsList = [pointsFromJson];
      }
    }

    // Safely handle all string fields
    String title = '';
    String content = '';
    String fullText = '';

    try {
      title = json['title']?.toString() ?? '';
      content = json['content']?.toString() ?? '';
      fullText = json['full_text']?.toString() ?? '';
    } catch (e) {
      print('Error parsing DailyTarotSection field: $e');
    }

    return DailyTarotSection(
      title: title,
      content: content,
      points: pointsList,
      fullText: fullText,
      sectionKey: key,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'points': points,
      'full_text': fullText,
    };
  }

  bool get hasPoints => points.isNotEmpty;
  bool get hasContent => content.isNotEmpty;
  bool get hasFullText => fullText.isNotEmpty;
}
