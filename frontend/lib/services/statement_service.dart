import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class StatementService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/statement';
  final _storage = const FlutterSecureStorage();

  Future<File?> downloadStatement({
    required String iban,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // 1. Luăm token-ul salvat
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return null;

      // 2. Construim URL-ul cu parametri
      final url = Uri.parse(
        '$baseUrl?iban=$iban&start=${start.toIso8601String().split('T')[0]}&end=${end.toIso8601String().split('T')[0]}',
      );

      // 3. Trimitem cererea cu token
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // 4. Salvăm fișierul PDF într-un folder temporar
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/extras_$iban.pdf');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Eroare: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Eroare rețea: $e');
      return null;
    }
  }
}