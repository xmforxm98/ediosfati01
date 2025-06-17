import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:innerfive/models/daily_tarot.dart';

class ApiService {
  // NOTE: The documentation specifies the full URL for each function.
  final String _analyzeAllUrl = 'https://analyze-all-nkggwr652q-uc.a.run.app';
  final String _dailyTarotUrl =
      'https://generate-daily-fortune-nkggwr652q-uc.a.run.app';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getAnalysisReport(
    Map<String, dynamic> userData,
  ) async {
    final url = Uri.parse(_analyzeAllUrl);
    try {
      print('🌐 API Request to: $url');
      print('🌐 Request Data: ${jsonEncode(userData)}');

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print('🌐 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        // Inject raw_data_for_dev for compatibility with existing models
        decodedBody['raw_data_for_dev'] = decodedBody;
        return decodedBody;
      } else {
        print('❌ API Call Failed with status ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception('API Call Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Network Error: $e');
      throw Exception('Network Error: $e');
    }
  }

  /// Fetches the daily tarot reading based on the user's profile.
  Future<DailyTarot> getDailyTarot(Map<String, dynamic> userProfile) async {
    final url = Uri.parse(_dailyTarotUrl);
    final requestBody = {
      'fortune_type': 'tarot',
      'user_profile': userProfile,
    };

    print('🌐 API Request to: $url');
    print('🌐 Request Data: ${jsonEncode(requestBody)}');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('🌐 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        return DailyTarot.fromJson(decodedBody);
      } else {
        print('❌ Failed to get daily tarot: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception(
            'Failed to get daily tarot reading: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error calling getDailyTarot API: $e');
      throw Exception('Error calling getDailyTarot API: $e');
    }
  }
}
