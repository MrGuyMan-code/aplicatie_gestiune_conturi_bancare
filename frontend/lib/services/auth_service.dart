import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Adresa serverului Spring Boot (10.0.2.2 este localhost-ul calculatorului văzut din emulatorul Android)
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';
  
  // Obiect pentru salvarea securizată a token-ului
  final _storage = const FlutterSecureStorage();

Future<Map<String, dynamic>?> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await _storage.write(key: 'jwt_token', value: data['token']);
      }
      return data; // succes
    } else {
      // Returnăm mesajul de eroare primit de la server
      return {'error': response.body};
    }
  } catch (e) {
    return {'error': 'Eroare de rețea: $e'};
  }
}

    Future<List<dynamic>?> getMyAccounts() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/accounts'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Eroare la obținerea conturilor: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Eroare rețea: $e');
      return null;
    }
  }

  // Funcție ajutătoare pentru logout (o vom folosi mai târziu)
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}