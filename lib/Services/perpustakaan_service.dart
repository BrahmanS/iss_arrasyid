import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iss/Services/config.dart';
class PerpustakaanService {
  final String baseUrl = Config.baseUrl;

  PerpustakaanService();

  Future<List<dynamic>> fetchMediaStatus(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/get_media_status');
    final response = await http.get(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      print('Failed to load media status with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }

  Future<List<dynamic>> fetchQueueRequests(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/get_queue_user');
    final response = await http.get(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      print('Failed to load loan requests with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }

  Future<bool> createMediaQueue(String sessionId, int mediaId, String dateFrom, String dateTo) async {
    final url = Uri.parse('$baseUrl/api/create_media_queue');
    final response = await http.post(
      url,
      headers: {
        'Cookie': 'session_id=$sessionId',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'media_id': mediaId,
        'date_from': dateFrom,
        'date_to': dateTo,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create media queue with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

}
