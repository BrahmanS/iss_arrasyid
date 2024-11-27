import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iss/Services/config.dart';
class ParentService {
  final String baseUrl = Config.baseUrl;

  ParentService();

  Future<Map<String, dynamic>> getChildrenData(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/children');
    final response = await http.get(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load children data');
    }
  }

  Future<Map<String, dynamic>?> getParentData(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/parent_data');
    final response = await http.get(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['parent'];
    } else {
      throw Exception('Failed to load parent data');
    }
  }

  Future<List<dynamic>> fetchSubmittedAssignmentsChildren(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/submitted_assignments_children');
    final response = await http.get(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['submitted_assignments'];
    } else {
      print('Failed to load assignments with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchClassYearData(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/classyear'),
      headers: {
        // 'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return data['data'];
      } else {
        throw Exception('Failed to load class and year data');
      }
    } else {
      throw Exception('Failed to load class and year data');
    }
  }

  Future<Map<String, dynamic>> searchRaport({
    required String sessionId,
    required int studentId,
    required int kelasId,
    required String semesterId,
    required int tahunPelajaran,
    required String jenisRaport,
  }) async {
    final url = Uri.parse('$baseUrl/api/search_raport');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: json.encode({
        'student_id': studentId,
        'kelas_id': kelasId,
        'semester_id': semesterId,
        'tahun_pelajaran': tahunPelajaran,
        'jenis_raport': jenisRaport,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load raport data');
    }
  }

  
}
