import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iss/Services/config.dart';
class StudentService {

  final String baseUrl = Config.baseUrl;

  StudentService();

  Future<Map<String, dynamic>?> getStudentData(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/student_data');
    final response = await http.get(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['student'];
    } else {
      throw Exception('Failed to load student data');
    }
  }
}
