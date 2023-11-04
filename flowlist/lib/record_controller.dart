// auth_model.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_service.dart';
import 'package:intl/intl.dart';

class RecordController {
  final storageService = StorageService();

  Future<String?> getRecordForDay(DateTime selectedDay) async {
    // URL vašeho API endpointu pro přihlášení
    const String baseUrl = "https://www.flow-list.cz/api/v1";

    // Převeďte vaše parametry na řetězec formátu query
    String? userId = await storageService.storage.read(key: 'userId');
    String date = DateFormat('yyyy-MM-dd').format(selectedDay);
    String? accessToken = await storageService.storage.read(key: 'accessToken');

    // Vytvoření URL s využitím vašich proměnných
    String url =
        "$baseUrl/users/$userId/records/$date?accessToken=$accessToken";
    try {
      // Odeslání GET požadavku
      final response = await http.get(Uri.parse(url));
      // Zkontrolujte stavový kód a analyzujte tělo odpovědi
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['record1'];
      } else {
        throw Exception('Chyba při stahovani: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
