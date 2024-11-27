import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:iss/Services/config.dart';

class AssignmentService {
  final String baseUrl = Config.baseUrl;

  AssignmentService();

  Future<List<dynamic>> fetchAssignments(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/assignment_user_batch');
    final response = await http.get(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['assignments'];
    } else {
      print('Failed to load assignments with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }

  // Future<int> fetchAssignmentCount(String sessionId) async {
  //   final url = Uri.parse('$baseUrl/api/assignment_count');
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Cookie': 'session_id=$sessionId',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     if (data['result'] != null && data['result']['status'] == 200) {
  //       return data['result']['assignment_count'];
  //     } else {
  //       throw Exception('Failed to load assignments: ${data['error'] ?? 'Unknown error'}');
  //     }
  //   } else {
  //     print('Failed to load assignments with status code: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //     throw Exception('Failed to load assignments');
  //   }
  // }

  Future<List<dynamic>> fetchSubmittedAssignments(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/submitted_assignments_batch');
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

  Future<void> submitAssignment({
    required String sessionId,
    required int taskId,
    required String studentName,
    required File file,
    required DateTime submissionDate,
  }) async {
    final url = Uri.parse('$baseUrl/api/submit_assignment');
    
    var request = http.MultipartRequest('POST', url)
      ..headers['Cookie'] = 'session_id=$sessionId'
      ..fields['assignment_id'] = taskId.toString()
      ..fields['student_name'] = studentName
      ..fields['submission_date'] = submissionDate.toIso8601String();

    var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();
    var multipartFile = http.MultipartFile(
      'file',
      stream,
      length,
      filename: file.path.split('/').last,
      contentType: MediaType('application', 'octet-stream'),
    );

    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);
      if (data['status'] == 200) {
        print('Assignment submitted successfully');
      } else {
        throw Exception('Failed to submit assignment: ${data['message']}');
      }
    } else {
      throw Exception('Failed to submit assignment with status code: ${response.statusCode}');
    }
  }


}
