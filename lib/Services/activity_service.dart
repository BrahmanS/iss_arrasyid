import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iss/Services/config.dart';

class ActivityService {
  final String baseUrl = Config.baseUrl;

  ActivityService();

  Future<Map<String, dynamic>> fetchActivities(String sessionId) async {
    final url = '$baseUrl/api/get_activities';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        // 'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load activities');
    }
  }
}
