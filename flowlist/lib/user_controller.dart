import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'user_profile.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserController {
  final String baseUrl = "https://jakub-jerabek.cz/flowlist";
  final storageService = StorageService();

  Future<UserProfile> getUserData([String? userId]) async {
    userId ??= await StorageService().getUserId();

    final response =
        await http.get(Uri.parse('$baseUrl/getUserData.php?userId=$userId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> user = json.decode(response.body);

      String firstName = user['firstName'] ?? 'Jan';
      String lastName = user['lastName'] ?? 'Novak';

      if (user['profileImg'] != null) {
        File? profileImageFile;
        var imageString = user['profileImg'];
        var imageBytes = base64Decode(imageString.split(',')[1]);

        // Uložení obrázku jako souboru
        String fileName =
            'profile_$userId.jpg'; // Jednoduché pojmenování souboru
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/$fileName';
        profileImageFile = File(filePath);
        await profileImageFile.writeAsBytes(imageBytes);
        return UserProfile(
            userId: int.parse(userId!),
            firstName: firstName,
            lastName: lastName,
            profileImage: filePath,
            hasPsychologist: user['hasPsychologist']);
      } else {
        return UserProfile(
            userId: int.parse(userId!),
            firstName: firstName,
            lastName: lastName,
            profileImage: null,
            hasPsychologist: user['hasPsychologist']);
      }
    } else {
      throw Exception('Failed to get user name: ${response.body}');
    }
  }

  Future<void> updateUserName(String name) async {
    String? userId = await StorageService().getUserId();

    List<String> nameParts = name.split(' ');
    String firstName = nameParts[0];
    String lastName = nameParts.length > 1 ? nameParts[1] : '';

    if (firstName.isEmpty || lastName.isEmpty) {
      throw Exception('Jméno nemůže být prázdné');
    }

    final Map<String, dynamic> data = {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/update_name.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data, // Odesílání dat jako Map
    );

    if (response.statusCode == 200) {
      //Map<String, dynamic> respond = json.decode(response.body);
      return;
    } else {
      throw Exception('Chyba při změně jména: ${response.body}');
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    String? userId = await StorageService().getUserId();
    Uri apiUrl = Uri.parse(
        '$baseUrl/updateUserPhoto.php'); // Nahraďte správnou URL vašeho API

    // Předpokládáme, že 'imagePath' je cesta k obrázku na zařízení
    var request = http.MultipartRequest('POST', apiUrl)
      ..fields['userId'] = userId ?? ''
      ..files.add(await http.MultipartFile.fromPath('profileImg', imagePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      // Zpracování úspěšné odpovědi
    } else {
      // Zpracování chyby
      throw Exception("Chyba pri aktualizaci profiloveho obrazku");
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    String? userId = await StorageService().getUserId();

    final response = await http.delete(
      Uri.parse('$baseUrl/getStatistics.php?userId=$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Pri mazani zaznamu doslo k chybe');
    }
  }

  Future<bool> deleteAccount() async {
    String? userId = await StorageService().getUserId();

    final response = await http.delete(
      Uri.parse('$baseUrl/deleteAccount.php?userId=$userId'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Pri mazani zaznamu doslo k chybe ${response.body}');
    }
  }
}

final userController = UserController();
