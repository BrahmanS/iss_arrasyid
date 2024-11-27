import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iss/Services/config.dart';
class JadwalService {
  final String baseUrl = Config.baseUrl;

  JadwalService();

  // Future<Map<String, dynamic>> getUserSessions(String sessionId) async {
  //   final maxRetries = 5;
  //   int retryAttempt = 0;
  //   late Map<String, dynamic> responseData;

  //   while (retryAttempt < maxRetries) {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('$baseUrl/api/sessions'),
  //         headers: {
  //           'Cookie': 'session_id=$sessionId',
  //         },
  //       ).timeout(Duration(seconds: 30));

  //       if (response.statusCode == 200) {
  //         responseData = json.decode(response.body);
  //         break;
  //       } else {
  //         throw Exception('Failed to load sessions');
  //       }
  //     } catch (error) {
  //       print('Error fetching sessions: $error');
  //       retryAttempt++;
  //       if (retryAttempt == maxRetries) {
  //         throw Exception('Max retries reached, failed to load sessions');
  //       }
  //       await Future.delayed(Duration(seconds: 2)); // Wait before retrying
  //     }
  //   }

  //   return responseData;
  // }
  Future<Map<String, dynamic>> getUserSessions(String sessionId, {required int month, required int year}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions?month=$month&year=$year'),
        headers: {
          'Cookie': 'session_id=$sessionId',
        },
      ).timeout(Duration(seconds: 60)); // Timeout increased to handle large data

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching sessions: $error');
      throw Exception('Failed to load sessions, Error: $error');
    }
  }


  // Future<Map<String, dynamic>> getChildrenSessions(String sessionId) async {
  //   final maxRetries = 5;
  //   int retryAttempt = 0;
  //   late Map<String, dynamic> responseData;

  //   while (retryAttempt < maxRetries) {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('$baseUrl/api/sessions_parent'),
  //         headers: {
  //           'Cookie': 'session_id=$sessionId',
  //         },
  //       ).timeout(Duration(seconds: 30)); // Timeout set to 30 seconds

  //       if (response.statusCode == 200) {
  //         responseData = json.decode(response.body);
  //         break; // Exit the loop if successful
  //       } else {
  //         throw Exception('Failed to load sessions');
  //       }
  //     } catch (error) {
  //       print('Error fetching sessions: $error');
  //       retryAttempt++;
  //       if (retryAttempt == maxRetries) {
  //         throw Exception('Max retries reached, failed to load sessions');
  //       }
  //       await Future.delayed(Duration(seconds: 2)); // Wait before retrying
  //     }
  //   }

  //   return responseData;
  // }
  Future<Map<String, dynamic>> getChildrenSessions(String sessionId, {required int month, required int year}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions_parent?month=$month&year=$year'),
        headers: {
          'Cookie': 'session_id=$sessionId',
        },
      ).timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching sessions: $error');
      throw Exception('Failed to load sessions, Error: $error');
    }
  }


  Future<List<Map<String, dynamic>>> getCalendarEvents(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/get_calendar_events'),
        headers: {
          // 'Content-Type': 'application/json',
          'Cookie': 'session_id=$sessionId',
        },
        
      ).timeout(Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((event) => event as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load calendar events');
      }
    } catch (e) {
      print('Error in getCalendarEvents: $e');
      throw Exception('Failed to load calendar events');
    }
  }

}
