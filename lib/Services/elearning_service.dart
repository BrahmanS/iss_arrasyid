import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iss/Services/config.dart';
class ELearningService {
  final String baseUrl = Config.baseUrl;

  ELearningService();

  Future<Map<String, dynamic>> fetchUserQuizzes(String sessionId) async {
    final url = '$baseUrl/api/get_user_quizzes';
    print('Fetching quizzes from URL: $url with session ID: $sessionId');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        // 'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
    );


    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  Future<Map<String, dynamic>> fetchChildQuizzes(String sessionId) async {
    final url = '$baseUrl/api/get_child_quizzes';
    print('Fetching child quizzes from URL: $url with session ID: $sessionId');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Cookie': 'session_id=$sessionId',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load child quizzes');
    }
  }
}
