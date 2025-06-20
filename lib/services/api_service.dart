import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:innerfive/models/daily_tarot.dart';

class ApiService {
  final String _baseUrl = 'https://api-nkggwr652q-uc.a.run.app';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getAnalysisReport(
    Map<String, dynamic> userData,
  ) async {
    final url = Uri.parse('$_baseUrl/analyze-all');
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
        print('✅ API Response Body: $decodedBody');
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
    final url = Uri.parse('$_baseUrl/generate-daily-fortune');

    // 백엔드가 기대하는 형식: 최상위 레벨에 필요한 필드들
    final requestBody = {
      'fortune_type': 'tarot',
      'user_name': userProfile['name'],
      'life_path_number': userProfile['life_path_number'],
      'day_master': userProfile['day_master'],
      'user_profile': userProfile, // 전체 프로필도 포함 (향후 확장용)
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
        print('✅ Daily Tarot API Response: $decodedBody');
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
