import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'package:intl/intl.dart';
import 'flow.dart';

class DiaryController {
  final String baseUrl = "https://jakub-jerabek.cz/flowlist";
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

    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      // Předpokládáme, že userId je String. Pokud je int, použijte toString().
      String userId = result['userId'];
      return userId;
    } else {
      throw Exception('Pri identifikaci uzivatele doslo k chybe');
    }
  }

  Future<dynamic> createEntry(FlowData record) async {
    String? userId = await StorageService().getUserId();

    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/create_entry.php'));
    request.fields.addAll({
      'userId': userId!,
      'date': DateFormat('yyyy-MM-dd').format(record.day),
      'record1': record.record1,
      'record2': record.record2,
      'record3': record.record3,
      'score': record.score.toString(),
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return response.statusCode;
    } else {
      throw Exception('Pri vytvareni zaznamu doslo k chybe');
    }
  }

  Future<List<FlowData>> readEntries() async {
    String? userId = await StorageService().getUserId();

    final response =
        await http.get(Uri.parse('$baseUrl/read_entry.php?userId=$userId'));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      List<FlowData> records =
          List<FlowData>.from(l.map((model) => FlowData.fromJson(model)));
      return records;
    } else {
      throw Exception('Pri cteni zaznamu doslo k chybe');
    }
  }

  Future<List<Map<String, dynamic>>> readEntry(DateTime selectedDay,
      [String? userId]) async {
    userId ??= await StorageService().getUserId();

    String date = DateFormat('yyyy-MM-dd').format(selectedDay);

    final response = await http
        .get(Uri.parse('$baseUrl/read_entry.php?userId=$userId&date=$date'));

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);

      if (responseData.isEmpty) {
        return [];
      }
      List<Map<String, dynamic>> entries = List<Map<String, dynamic>>.from(
          responseData.map((entry) => Map<String, dynamic>.from(entry)));

      return entries;
    } else {
      throw Exception('Pri cteni zaznamu doslo k chybe');
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
      throw Exception('Pri aktualizaci zaznamu doslo k chybe');
    }
  }

  Future<dynamic> deleteEntry(DateTime date) async {
    String? userId = await StorageService().getUserId();
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_entry.php?userId=$userId&date=$formattedDate'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Pri mazani zaznamu doslo k chybe');
    }
  }
}

final diaryController = DiaryController();
