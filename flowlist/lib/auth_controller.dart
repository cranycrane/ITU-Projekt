// auth_model.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class AuthController {
  final storageService = StorageService();

  Future<String?> signIn(String email, String password) async {
    // URL vašeho API endpointu pro přihlášení
    const String baseUrl = "https://www.flow-list.cz/api/v1/tokenPassword";

    // Převeďte vaše parametry na řetězec formátu query
    final String queryParameters = Uri(queryParameters: {
      'login': email,
      'password': password,
    }).query;

    final String apiUrl = "$baseUrl?$queryParameters";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        await storageService.storage
            .write(key: 'accessToken', value: responseData['accessToken']);
        await storageService.storage
            .write(key: 'userId', value: responseData['userId']);
      } else {
        throw Exception('Chyba při přihlašování: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
