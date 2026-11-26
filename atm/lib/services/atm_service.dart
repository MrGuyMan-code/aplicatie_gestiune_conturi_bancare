import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AtmService {
  // ATENȚIE: pentru web (browser) folosim localhost, nu 10.0.2.2
  static const String baseUrl = 'http://localhost:8080/api';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _storage.write(key: 'jwt_token', value: data['token']);
        }
        return data;
      }
      return null;
    } catch (e) {
      print('Eroare login: $e');
      return null;
    }
  }

  Future<String?> deposit(String iban, double amount) async {
    return _callAtm('deposit', iban, amount);
  }

  Future<String?> withdraw(String iban, double amount) async {
    return _callAtm('withdraw', iban, amount);
  }

  Future<String?> _callAtm(String action, String iban, double amount) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return "Eroare: Nu ești autentificat.";

      final response = await http.post(
        Uri.parse('$baseUrl/atm/$action'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'iban': iban, 'amount': amount}),
      );

      if (response.statusCode == 200) {
        return null; // succes
      } else {
        return response.body; // mesajul de eroare de la backend
      }
    } catch (e) {
      return "Eroare de rețea: $e";
    }
  }
}