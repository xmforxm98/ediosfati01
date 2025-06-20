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
      // 1. Extract required data from the userProfile based on the new guide.
      // The guide specifies 'eidos_group_name' from the analysis report.
      // 'userProfile.eidosType' maps to 'eidos_type' at the root of the analysis JSON.
      String eidosType = 'Default';
      String lifePathNumber = '3';
      String dayMaster = 'Fire';

      if (userProfile != null) {
        // Try to get eidos type from multiple sources
        eidosType = userProfile.eidosType ??
            userProfile.eidosSummary.eidosType ??
            userProfile.eidosSummary.summaryTitle ??
            'Default';

        // Try to get life path number and day master from rawDataForDev
        if (userProfile.rawDataForDev.isNotEmpty) {
          lifePathNumber =
              userProfile.rawDataForDev['life_path_number']?.toString() ?? '3';
          dayMaster =
              userProfile.rawDataForDev['day_master']?.toString() ?? 'Fire';
        }
      }

      final int intLifePathNumber = int.tryParse(lifePathNumber) ?? 3;

      // Ensure username is ASCII as per the guide
      final safeUserName = userName.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
      final finalUserName = safeUserName.isNotEmpty ? safeUserName : 'User';

      print('🌟 Fortune API Request Data:');
      print('   - fortuneType: $fortuneType');
      print('   - userName: $finalUserName');
      print('   - eidosType: $eidosType');
      print('   - lifePathNumber: $intLifePathNumber');
      print('   - dayMaster: $dayMaster');

      // 2. Construct the request body according to the new API specification.
      final apiRequestData = {
        'fortune_type': fortuneType.toLowerCase(),
        'user_name': finalUserName,
        'life_path_number': intLifePathNumber,
        'day_master': dayMaster,
        'eidos_type': eidosType, // Pass the correct eidos type here
      };

      // 3. Make the API call.
      final response = await http.post(
        Uri.parse(_fortuneUrl),
        headers: {
          'Content-Type': 'application/json',
          // Add any other required headers like auth tokens if needed
        },
        body: jsonEncode(apiRequestData),
      );

      print('🌟 Fortune API Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('🌟 Fortune API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🌟 Fortune API Success Response: $data');
        _setLastFetchedDate(fortuneType);
        return _convertApiResponseToFortune(data, fortuneType);
      } else {
        print(
            '❌ Failed to load daily fortune. Status: ${response.statusCode}, Body: ${response.body}');
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
    print('🔍 Converting API response for fortune type: $typeLower');
    print('🔍 API response keys: ${apiResponse.keys.toList()}');

    // Handle non-Tarot fortunes (Love, Career, Eidos etc.)
    final readingKey = 'daily_${typeLower}_reading';
    print('🔍 Looking for reading key: $readingKey');

    if (apiResponse.containsKey(readingKey) && apiResponse[readingKey] is Map) {
      print('✅ Found reading data for $readingKey');
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

      final result = {
        'title': "Today's $fortuneType Insights",
        'description': finalDescription,
        'theme': readingData['theme'] ?? 'General',
        'lucky_color': readingData['lucky_color'] ?? 'White',
        'imageUrl': _getDefaultImageUrl(fortuneType),
      };
      print('✅ Returning non-tarot result: $result');
      return result;
    }

    // Handle Tarot specifically
    if (typeLower == 'tarot' && apiResponse.containsKey('daily_tarot_draw')) {
      print('✅ Found tarot data');
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

      final result = {
        'title': tarotReading['card_name_display'] ?? 'Today\'s Tarot',
        'description': description,
        'imageUrl': imageUrl,
      };
      print('✅ Returning tarot result: $result');
      return result;
    }

    // Fallback for old format or errors
    print('⚠️ Using fallback result');
    final fallbackResult = {
      'title': "Today's Fortune",
      'description': apiResponse['fortune_message']?.toString() ??
          'Your fortune is waiting.',
      'imageUrl': _getDefaultImageUrl(fortuneType),
    };
    print('⚠️ Fallback result: $fallbackResult');
    return fallbackResult;
  }

  static String _getDefaultImageUrl(String fortuneType) {
    if (fortuneType.toLowerCase() == 'tarot') {
      return 'https://storage.googleapis.com/innerfive-storage/golden_sage/The%20visionary%20verdant%20oracle%20of%20golden%20sage1.jpg';
    }
    return 'https://storage.googleapis.com/innerfive-storage/golden_sage/The%20visionary%20verdant%20oracle%20of%20golden%20sage2.jpg';
  }

  // New method for Eidos Daily Fortune
  Future<Map<String, dynamic>> generateEidosDailyFortune(
    String userName,
    String birthDate,
    String dayMaster,
    int lifePathNumber,
  ) async {
    try {
      final apiRequestData = {
        'user_name': userName,
        'fortune_type': 'eidos',
        'birth_date': birthDate,
        'day_master': dayMaster,
        'life_path_number': lifePathNumber,
      };

      print('🌟 Eidos Fortune API Request Data:');
      print('   - userName: $userName');
      print('   - birthDate: $birthDate');
      print('   - dayMaster: $dayMaster');
      print('   - lifePathNumber: $lifePathNumber');

      final response = await http.post(
        Uri.parse(_fortuneUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(apiRequestData),
      );

      print('🌟 Eidos Fortune API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🌟 Eidos Fortune API Success Response: $data');
        _setLastFetchedDate('eidos');
        return _convertEidosApiResponse(data);
      } else {
        print(
            '❌ Failed to load Eidos daily fortune. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load Eidos daily fortune: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in generateEidosDailyFortune: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _convertEidosApiResponse(
      Map<String, dynamic> apiResponse) {
    print('🔍 Converting Eidos API response');
    print('🔍 API response keys: ${apiResponse.keys.toList()}');

    if (apiResponse.containsKey('daily_eidos_reading')) {
      final eidosReading =
          apiResponse['daily_eidos_reading'] as Map<String, dynamic>;

      // Extract conversational reading
      final conversationalReading =
          eidosReading['conversational_reading'] as Map<String, dynamic>?;
      final immediateAction =
          eidosReading['immediate_action'] as Map<String, dynamic>?;
      final eidosEssence =
          eidosReading['eidos_essence'] as Map<String, dynamic>?;

      // Build description from multiple parts
      List<String> descriptionParts = [];

      if (conversationalReading?['opening'] != null) {
        descriptionParts.add(conversationalReading!['opening'].toString());
      }

      if (eidosEssence?['cosmic_message'] != null) {
        descriptionParts
            .add("\n✨ Cosmic Message:\n${eidosEssence!['cosmic_message']}");
      }

      if (conversationalReading?['personal_insight'] != null) {
        descriptionParts.add(
            "\n💡 Personal Insight:\n${conversationalReading!['personal_insight']}");
      }

      if (immediateAction?['suggestion'] != null) {
        descriptionParts
            .add("\n🎯 Today's Action:\n${immediateAction!['suggestion']}");
      }

      if (conversationalReading?['closing'] != null) {
        descriptionParts.add("\n${conversationalReading!['closing']}");
      }

      final result = {
        'title': eidosReading['title'] ?? "Today's Eidos Insights",
        'description': descriptionParts.join('\n\n'),
        'archetype_name': eidosEssence?['archetype_name'] ?? 'Your Eidos',
        'daily_alignment': eidosEssence?['daily_alignment'] ?? 'Cosmic Energy',
        'energy_state': immediateAction?['energy_state'] ?? 'balanced',
        'timing': immediateAction?['timing'] ?? 'perfect timing',
        'theme': 'Eidos Essence',
      };

      print('✅ Returning Eidos result: $result');
      return result;
    }

    // Fallback
    return {
      'title': "Today's Eidos Insights",
      'description': 'Your Eidos guidance is being prepared...',
      'archetype_name': 'Your Eidos',
      'theme': 'Eidos Essence',
    };
  }
}
