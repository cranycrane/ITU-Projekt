import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'user_profile.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PsychoController {
  final String baseUrl = "https://jakub-jerabek.cz/flowlist";
  final storageService = StorageService();

  Future<Map<String, dynamic>> getPairingCode() async {
    String? userId = await StorageService().getUserId();

    final response = await http.delete(
      Uri.parse('$baseUrl/getPsychologistCode.php?userId=$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Pri mazani zaznamu doslo k chybe');
    }
  }

  Future<bool> pairWithClient(String pairingCode) async {
    String? userId = await StorageService().getUserId();

    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/pairPsychologist.php'));
    request.fields.addAll({
      'psychologistId': userId!,
      'pairingCode': pairingCode,
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Pri vytvareni zaznamu doslo k chybe');
    }
  }

  Future<void> unPairWithClient(UserProfile client) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/unpairPsychologist.php'));
    request.fields.addAll({
      'userId': client.userId.toString(),
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Uživatel nebyl nalezen');
    } else {
      throw Exception('Při rušení párování s uživatelem došlo k chybě');
    }
  }

  Future<List<UserProfile>> getPairedUsers() async {
    String? userId = await StorageService().getUserId();

    final response = await http.delete(
      Uri.parse('$baseUrl/psychologistClients.php?psychologistId=$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> clientsJson = json.decode(response.body);
      return clientsJson.map((json) => UserProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<File?> getUserPhoto(UserProfile user) async {
    if (user.profileImage == null || user.profileImage!.isEmpty) return null;

    // Získání URL obrázku (předpokládá se, že profileImagePath je URL)
    final response =
        await http.get(Uri.parse("$baseUrl/uploads/${user.profileImage!}"));

    // Získání dočasného adresáře
    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/user_${user.userId}.png';

      // Uložení souboru
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } else {
      // Pokud se obrázek nepodaří stáhnout, můžete vrátit null nebo zobrazit chybu
      throw Exception('Failed to download user photo: ${response.body}');
    }
  }
}

final psychoController = PsychoController();
