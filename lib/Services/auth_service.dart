import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iss/Services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  final String baseUrl = Config.baseUrl;

  AuthService();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'db': 'arrasyid-bsd.id',
          'login': email,
          'password': password,
        },
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Response Data: $responseData');
      if (responseData['result'] != null) {
        final sessionId = response.headers['set-cookie'];
        return {
          'session_id': sessionId,
          ...responseData['result'],
        };
      } else if (responseData['error'] != null) {
        throw Exception(responseData['error']['data']['message']);
      }
    } else if (response.statusCode == 401) {
      throw Exception('Email atau Password salah');
    }else {
      throw Exception('Gagal login');
    }
  }




  Future<void> logout(String sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/logout'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'db': 'arrasyid-bsd.id',
          'session_id': sessionId,
          
        },
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // if (response.statusCode != 200) {
    //   throw Exception('Failed to logout');
    // }
    if (response.statusCode != 200) {
    // Tambahkan detail error dari response body jika ada
    final errorMessage = response.body.isNotEmpty
        ? jsonDecode(response.body)['error']['message'] ?? 'Unknown error'
        : 'Failed to logout with status code ${response.statusCode}';
    throw Exception(errorMessage);
  }
  }

}
