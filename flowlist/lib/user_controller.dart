import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'user_profile.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserController {
  final String baseUrl = "http://10.0.2.2:8000";
  final storageService = StorageService();

  Future<UserProfile> getUserData() async {
    String? userId = await StorageService().getUserId();

    final response =
        await http.get(Uri.parse('$baseUrl/getUserData.php?userId=$userId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> user = json.decode(response.body);

      String firstName = user['firstName'] ?? '';
      String lastName = user['lastName'] ?? '';

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
            firstName: firstName,
            lastName: lastName,
            profileImage: profileImageFile);
      } else {
        return UserProfile(
            firstName: firstName, lastName: lastName, profileImage: null);
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
      throw Exception('Failed to get user name: ${response.body}');
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
      print('Profilový obrázek byl úspěšně aktualizován.');
    } else {
      // Zpracování chyby
      print(
          'Chyba při aktualizaci profilového obrázku: ${response.statusCode}');
    }
  }
}

final userController = UserController();
