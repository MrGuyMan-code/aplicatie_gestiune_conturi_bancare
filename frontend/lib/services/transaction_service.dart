import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/transactions';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> getTransactions({
    required String iban,
    required int page,
    int size = 20,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return null;

      final url = Uri.parse('$baseUrl?iban=$iban&page=$page&size=$size');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // conține content, totalPages, number, etc.
      } else {
        print('Eroare: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Eroare rețea: $e');
      return null;
    }
  }
}