import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/';

  static Future<Map<String, dynamic>> createOrder(int amount, String userAddress) async {
    final response = await http.post(
      Uri.parse('${baseUrl}create-order/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount, 'userAddress': userAddress}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }
}