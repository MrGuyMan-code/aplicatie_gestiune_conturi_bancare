import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Adresa serverului Spring Boot (10.0.2.2 este localhost-ul calculatorului văzut din emulatorul Android)
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';
  
  // Obiect pentru salvarea securizată a token-ului
  final _storage = const FlutterSecureStorage();

  // Funcția care face login-ul
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // 1. Trimitem cererea POST către Spring Boot
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // 2. Verificăm dacă răspunsul este OK (200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 3. Salvăm token-ul în memoria securizată a telefonului
        if (data['token'] != null) {
          await _storage.write(key: 'jwt_token', value: data['token']);
        }
        
        // 4. Returnăm datele primite (token + lista de conturi)
        return data;
      } else {
        print('Eroare login: ${response.statusCode} - ${response.body}');
        return null; // Login eșuat
      }
    } catch (e) {
      print('Eroare de rețea: $e');
      return null;
    }
  }

  // Funcție ajutătoare pentru logout (o vom folosi mai târziu)
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}