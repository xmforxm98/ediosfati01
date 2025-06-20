import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_report.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyFortuneService {
  static final Map<String, String> _lastFetchedDates = {};

  static String? getLastFetchedDate(String fortuneType) {
    return _lastFetchedDates[fortuneType];
  }

  static void _setLastFetchedDate(String fortuneType) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _lastFetchedDates[fortuneType] = today;
  }

  static const String _fortuneUrl =
      'https://api-nkggwr652q-uc.a.run.app/generate-daily-fortune';

  Future<Map<String, dynamic>> generateDailyFortune(
    String fortuneType,
    NarrativeReport? userProfile,
    String userName,
  ) async {
    try {
      String? lifePathNumber;
      String? dayMaster;
      String? actualEidosType;

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final readingsQuery = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('readings')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (readingsQuery.docs.isNotEmpty) {
            final latestReading = readingsQuery.docs.first.data();
            if (latestReading.containsKey('report')) {
              final reportData =
                  latestReading['report'] as Map<String, dynamic>;

              lifePathNumber = reportData['life_path_number']?.toString();
              dayMaster = reportData['day_master']?.toString();
              final personalizedIntro = reportData['personalized_introduction']
                  as Map<String, dynamic>?;
              if (personalizedIntro != null) {
                final introOpening =
                    personalizedIntro['opening']?.toString() ?? '';
                final asAPattern = RegExp(r'As a (The [^,\.]+)');
                final match = asAPattern.firstMatch(introOpening);
                if (match != null) {
                  actualEidosType = match.group(1)?.trim();
                }
              }
              actualEidosType ??=
                  reportData['eidos_group_name']?.toString() ?? 'Unknown';
            }
          }
        }
      } catch (firestoreError) {
        print('🔍 Error fetching from Firestore: $firestoreError');
      }

      lifePathNumber ??= '3';
      dayMaster ??= 'Fire';
      final intLifePathNumber = int.tryParse(lifePathNumber) ?? 3;
      actualEidosType ??= 'Unknown';

      final apiRequestData = {
        'fortune_type': fortuneType,
        'user_name': userName,
        'life_path_number': intLifePathNumber,
        'day_master': dayMaster,
        'user_profile': {
          'eidos_type_name': actualEidosType,
          'summary_text': 'N/A',
          'current_energy_text': 'Your unique energy signature',
          'life_path_number': lifePathNumber,
          'day_master': dayMaster,
        },
        'current_date': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(_fortuneUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(apiRequestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _setLastFetchedDate(fortuneType);
        return _convertApiResponseToFortune(data, fortuneType);
      } else {
        throw Exception('Failed to load daily fortune: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in generateDailyFortune: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _convertApiResponseToFortune(
      Map<String, dynamic> apiResponse, String fortuneType) {
    final typeLower = fortuneType.toLowerCase();

    // Handle non-Tarot fortunes (Love, Career, Eidos etc.)
    final readingKey = 'daily_${typeLower}_reading';
    if (apiResponse.containsKey(readingKey) && apiResponse[readingKey] is Map) {
      final readingData = apiResponse[readingKey] as Map<String, dynamic>;
      final messageData = readingData['message'] as Map<String, dynamic>?;

      List<String> descriptionParts = [];
      if (messageData?['content'] != null) {
        descriptionParts.add(messageData!['content'].toString());
      }
      if (messageData?['sections'] is Map) {
        final sections = messageData!['sections'] as Map<String, dynamic>;
        if (sections['key_opportunity']?['content'] != null) {
          descriptionParts.add(
              "\\n✨ Key Opportunity:\\n${sections['key_opportunity']['content']}");
        }
        if (sections['guidance']?['content'] != null) {
          descriptionParts
              .add("\\n💡 Guidance:\\n${sections['guidance']['content']}");
        }
      }
      String finalDescription = descriptionParts.join('\\n\\n');
      if (finalDescription.isEmpty) {
        finalDescription = apiResponse['fortune_message']?.toString() ??
            'No specific guidance today. Focus on your inner strength.';
      }

      return {
        'title': "Today's $fortuneType Insights",
        'description': finalDescription,
        'theme': readingData['theme'] ?? 'General',
        'lucky_color': readingData['lucky_color'] ?? 'White',
        'imageUrl': _getDefaultImageUrl(fortuneType),
      };
    }

    // Handle Tarot specifically
    if (typeLower == 'tarot' && apiResponse.containsKey('daily_tarot_draw')) {
      final tarotReading =
          apiResponse['daily_tarot_draw'] as Map<String, dynamic>;
      String imageUrl = tarotReading['card_image_url'] ?? '';

      if (!imageUrl.startsWith('http') || imageUrl.contains('your-cdn.com')) {
        final cardId = tarotReading['card_id'] as String?;
        if (cardId != null && cardId.isNotEmpty) {
          final imageName = '$cardId.png';
          imageUrl =
              'https://firebasestorage.googleapis.com/v0/b/innerfive.firebasestorage.app/o/tarot_cards%2F${Uri.encodeComponent(imageName)}?alt=media';
          print('🎴 Constructed tarot image URL: $imageUrl');
        } else {
          print('🎴 Invalid tarot image URL and no card_id. Using default.');
          imageUrl = _getDefaultImageUrl('tarot');
        }
      }

      var description = "No reading available.";
      if (tarotReading['message'] is Map) {
        final messageData = tarotReading['message'] as Map<String, dynamic>;
        final descriptionParts = <String>[];
        if (messageData['content'] != null) {
          descriptionParts.add(messageData['content']);
        }
        if (messageData['sections'] is Map) {
          final sections = messageData['sections'];
          if (sections['card_revelation']?['content'] != null) {
            descriptionParts.add(
                "\\nCard Revelation:\\n${sections['card_revelation']['content']}");
          }
          if (sections['daily_actions']?['full_text'] != null) {
            descriptionParts.add(
                "\\nRecommended Actions:\\n${sections['daily_actions']['full_text']}");
          }
        }
        if (descriptionParts.isNotEmpty) {
          description = descriptionParts.join('\\n\\n');
        }
      }

      return {
        'title': tarotReading['card_name_display'] ?? 'Today\'s Tarot',
        'description': description,
        'imageUrl': imageUrl,
      };
    }

    // Fallback for old format or errors
    return {
      'title': "Today's Fortune",
      'description': apiResponse['fortune_message']?.toString() ??
          'Your fortune is waiting.',
      'imageUrl': _getDefaultImageUrl(fortuneType),
    };
  }

  static String _getDefaultImageUrl(String fortuneType) {
    if (fortuneType.toLowerCase() == 'tarot') {
      return 'https://storage.googleapis.com/innerfive-storage/golden_sage/The%20visionary%20verdant%20oracle%20of%20golden%20sage1.jpg';
    }
    return 'https://storage.googleapis.com/innerfive-storage/golden_sage/The%20visionary%20verdant%20oracle%20of%20golden%20sage2.jpg';
  }
}
