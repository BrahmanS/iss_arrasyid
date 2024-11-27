import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iss/Services/config.dart';
class InvoiceService {
  final String baseUrl = Config.baseUrl;

  InvoiceService();

  Future<Map<String, dynamic>> fetchInvoices(String sessionId) async {
    final url = '$baseUrl/api/get_invoices';
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
      throw Exception('Failed to load invoices');
    }
  }
}
