import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'package:intl/intl.dart';
import 'flow.dart';

class DiaryController {
  final String baseUrl = "http://10.0.2.2:8000";
  final storageService = StorageService();

  Future<String> getUserId(String? deviceId) async {
    final Map<String, dynamic> data = {
      'deviceId': deviceId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/getUserId.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data, // Odesílání dat jako Map
    );

    print("jsonData: $data");
    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      // Předpokládáme, že userId je String. Pokud je int, použijte toString().
      String userId = result['userId'];
      return userId;
    } else {
      Map<String, dynamic> result = json.decode(response.body);
      throw Exception('Failed to get userId: $result');
    }
  }

  Future<dynamic> createEntry(FlowData record) async {
    String? userId = await StorageService().getUserId();
    final Map<String, dynamic> data = {
      'userId': userId,
      'date': record.day,
      'record1': record.record1,
      'record2': record.record2,
      'record3': record.record3
    };

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

  Future<List<Map<String, dynamic>>> readEntry(DateTime selectedDay) async {
    String? userId = await StorageService().getUserId();
    String date = DateFormat('yyyy-MM-dd').format(selectedDay);

    final response = await http
        .get(Uri.parse('$baseUrl/read_entry.php?userId=$userId&date=$date'));

    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> responseData = json.decode(response.body);

      if (responseData.isEmpty) {
        return [];
      }
      List<Map<String, dynamic>> entries = List<Map<String, dynamic>>.from(
          responseData.map((entry) => Map<String, dynamic>.from(entry)));

      return entries;
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
