import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class DonationService {
  Future<List<dynamic>> fetchWakaf() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/wakaf'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data;
    } else {
      throw Exception('Failed to load wakaf data');
    }
  }

  Future<List<dynamic>> fetchDonasi() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/donasi'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['response'];
      return data;
    } else {
      throw Exception('Failed to load donasi data');
    }
  }

  Future<Map<String, dynamic>> fetchDonasiById(int donasiId) async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/donasi/$donasiId'));
    // print('Status Code: ${response.statusCode}');
    // print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['response'];
      return data;
    } else {
      throw Exception('Failed to load donation details');
    }
  }

  Future<Map<String, dynamic>> submitDonation({
    required String namaDonatur,
    required String email,
    required String phone,
    required String note,
    required int donasiId,
    required int nilaiDonasi,
  }) async {
    print('Sending donation data: $namaDonatur, $email, $phone, $donasiId, $nilaiDonasi');
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/api/donatur_and_donasi/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nama_donatur': namaDonatur,
        'email': email,
        'phone': phone,
        'note': note,
        'nilai_donasi': nilaiDonasi,
        'donasi_id': donasiId,
      }),
    );

    print('API Response Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit donation');
    }
  }

}
