import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_report.dart';

class DailyFortuneService {
  static const String _baseUrl =
      'https://us-central1-eidosfati.cloudfunctions.net';

  Future<Map<String, dynamic>> generateDailyFortune(
    String fortuneType,
    NarrativeReport? userProfile,
    String userName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate_daily_fortune'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fortuneType': fortuneType,
          'userName': userName,
          'userProfile': userProfile != null
              ? {
                  'eidosType': userProfile.eidosType,
                  'summaryText': userProfile.eidosSummary.summaryText,
                }
              : null,
          'currentDate': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to generate daily fortune: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in DailyFortuneService: $e');
      // Return fallback data
      return _getFallbackFortuneData(fortuneType, userName);
    }
  }

  Map<String, dynamic> _getFallbackFortuneData(
      String fortuneType, String userName) {
    final fortuneMessages = {
      'Love': {
        'title': 'Love & Connections',
        'subtitle': 'Your magnetic charm shines brightly today',
        'message':
            'Hey $userName! Your natural charisma creates powerful connections today. Whether meeting someone new or deepening existing bonds, your authentic self draws others in. Trust your instincts and let your heart guide you.',
        'keywords': [
          'Magnetic Attraction',
          'Authentic Connection',
          'Heart-led Choices'
        ],
      },
      'Career': {
        'title': 'Work & Purpose',
        'subtitle': 'Your skills create new opportunities',
        'message':
            '$userName, your professional energy is at its peak today. Your unique talents are being noticed. Perfect time to showcase your abilities, take on challenges, or make strategic career moves.',
        'keywords': [
          'Professional Growth',
          'Skill Recognition',
          'Strategic Opportunities'
        ],
      },
      'Wealth': {
        'title': 'Money & Abundance',
        'subtitle': 'Abundance flows through wise decisions',
        'message':
            'Your financial intuition is sharp today, $userName. Whether making smart investments, finding new income sources, or managing resources wisely, trust your practical judgment. Small actions today can lead to significant growth.',
        'keywords': [
          'Financial Wisdom',
          'Smart Investments',
          'Resource Management'
        ],
      },
      'Health': {
        'title': 'Wellness & Vitality',
        'subtitle': 'Your body and mind are in harmony',
        'message':
            '$userName, your energy levels are balanced and strong today. Perfect timing for both physical activities and mental pursuits. Listen to your body\'s needs and maintain harmony between rest and action.',
        'keywords': ['Balanced Energy', 'Mind-Body Harmony', 'Vital Strength'],
      },
      'Social': {
        'title': 'Relationships & Community',
        'subtitle': 'Your connections flourish through understanding',
        'message':
            'Your ability to connect with others is heightened today, $userName. Whether with family, friends, or colleagues, your empathy and communication skills create deeper bonds. Be open to giving and receiving support.',
        'keywords': [
          'Deep Connections',
          'Empathetic Communication',
          'Mutual Support'
        ],
      },
      'Growth': {
        'title': 'Learning & Evolution',
        'subtitle': 'New learning opportunities await',
        'message':
            'Today brings excellent opportunities for personal development, $userName. Your mind is open to new ideas and experiences. Embrace challenges as growth opportunities and trust in your ability to evolve.',
        'keywords': [
          'Personal Development',
          'Learning Opportunities',
          'Growth Mindset'
        ],
      },
      'Advice': {
        'title': 'Today\'s Guidance',
        'subtitle': 'The universe aligns to support your journey',
        'message':
            '$userName, today the cosmic energies align in your favor. Trust your intuition, stay open to unexpected opportunities, and remember that every experience contributes to your unique path. Your authentic self is your greatest strength.',
        'keywords': [
          'Cosmic Alignment',
          'Intuitive Guidance',
          'Authentic Path'
        ],
      },
    };

    return fortuneMessages[fortuneType] ?? fortuneMessages['Advice']!;
  }
}
