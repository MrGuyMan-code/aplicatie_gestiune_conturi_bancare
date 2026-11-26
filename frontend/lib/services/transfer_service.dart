import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransferService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/transfer';
  final _storage = const FlutterSecureStorage();

  Future<String?> executeTransfer({
    required String sourceIban,
    required String targetIban,
    required double amount,
    required String description,
    required String idempotencyKey, 
  }) async {
    try {
      // 1. Luăm token-ul JWT
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return "Eroare: Nu ești autentificat.";

      // 2. Trimitem cererea POST
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sourceIban': sourceIban,
          'targetIban': targetIban,
          'amount': amount,
          'description': description,
          'idempotencyKey': idempotencyKey,
        }),
      );

      // 3. Verificăm răspunsul
      if (response.statusCode == 200) {
        return null; // Succes (null înseamnă "fără eroare")
      } else {
        // Dacă serverul a returnat un mesaj de eroare (400), îl trimitem mai departe
        return response.body;
      }
    } catch (e) {
      return "Eroare de rețea: $e";
    }
  }
}