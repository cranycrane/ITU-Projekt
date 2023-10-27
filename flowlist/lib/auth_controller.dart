// auth_model.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthController {
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
        return responseData[
            'token']; // předpokládám, že váš server vrací token pod klíčem 'token'
      } else {
        throw Exception('Chyba při přihlašování: ${response.body}');
      }
    } catch (e) {
      throw e;
    }
  }
}
