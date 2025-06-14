import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Real Cloud Function URL after successful deployment
  static const String _baseUrl = 'https://analyze-all-nkggwr652q-uc.a.run.app';
  static const String _eidosUrl =
      'https://us-central1-eidosfati.cloudfunctions.net/analyze_eidos';

  // 로컬 에뮬레이터 테스트용 URL 예시:
  // static const String _baseUrl = 'http://10.0.2.2:5001/your-project-id/us-central1/analyze_all';

  Future<String> getAnalysisReport(Map<String, dynamic> userData) async {
    final url = Uri.parse(_baseUrl);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        // The API returns the full report JSON directly.
        return response.body;
      } else {
        // Detailed error for debugging
        final errorBody =
            'Request Body: ${jsonEncode(userData)}\n\n'
            'Response Code: ${response.statusCode}\n\n'
            'Response Body: ${response.body}';
        print('API Failed:\n$errorBody');
        throw Exception('API Call Failed:\n$errorBody');
      }
    } catch (e) {
      // Catch network or other errors
      final errorBody = 'Request Body: ${jsonEncode(userData)}\n\nError: $e';
      print('Error calling API:\n$errorBody');
      throw Exception('Network Error:\n$errorBody');
    }
  }

  static Future<Map<String, dynamic>> analyzeEidos({
    required String userInput,
    required String userName,
    required Map<String, dynamic> analysisData,
  }) async {
    final url = Uri.parse(_eidosUrl);
    try {
      final requestBody = {
        'userInput': userInput,
        'userName': userName,
        'analysisData': analysisData,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody =
            'Request Body: ${jsonEncode(requestBody)}\n\n'
            'Response Code: ${response.statusCode}\n\n'
            'Response Body: ${response.body}';
        print('Eidos API Failed:\n$errorBody');
        throw Exception('Eidos Analysis Failed:\n$errorBody');
      }
    } catch (e) {
      final errorBody =
          'Request Body: ${jsonEncode({'userInput': userInput, 'userName': userName})}\n\nError: $e';
      print('Error calling Eidos API:\n$errorBody');
      throw Exception('Network Error:\n$errorBody');
    }
  }

  Future<Map<String, dynamic>> fetchReport(
    Map<String, dynamic> userData,
  ) async {
    final response = await http.post(
      Uri.parse('https://YOUR_CLOUD_FUNCTION_URL'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load report');
    }
  }
}
