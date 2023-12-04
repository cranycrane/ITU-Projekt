import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'package:intl/intl.dart';

class DiaryController {
  final String baseUrl = "http://10.0.2.2:8000";
  final storageService = StorageService();

  Future<dynamic> createEntry(String record1, String record2, String record3,
      DateTime day, int score) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_entry'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create entry');
    }
  }

  Future<dynamic> readEntries(int creatorId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/read_entry.php?creator_id=$creatorId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to read entries');
    }
  }

  Future<String?> readEntry(DateTime selectedDay) async {
    String? deviceId = await StorageService().getDeviceId();
    String date = DateFormat('yyyy-MM-dd').format(selectedDay);

    final response = await http.get(Uri.parse(
        '$baseUrl/read_entry.php?deviceId=OSM1.180201.037&date=$date'));

    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> jsonData = json.decode(response.body);
      if (jsonData.isEmpty) {
        return "";
      } else {
        return jsonData[0]['record1'];
      }
    } else {
      throw Exception('Failed to read entries');
    }
  }

  Future<dynamic> updateEntry(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update_entry'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'id': id, ...data}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update entry');
    }
  }

  Future<dynamic> deleteEntry(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete_entry?id=$id'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete entry');
    }
  }
}

final diaryController = DiaryController();
