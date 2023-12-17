import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'message.dart';
import 'storage_service.dart';

class MessageController {
  final String baseUrl = "https://jakub-jerabek.cz/flowlist";
  final StreamController<List<Message>> _messagesStreamController =
      StreamController.broadcast();

  Stream<List<Message>> get messagesStream => _messagesStreamController.stream;

  void dispose() {
    _messagesStreamController.close();
  }

  //načtení zpráv uživatele
  void getMessages() async {
    String? userId = await StorageService().getUserId();

    final response =
        await http.get(Uri.parse('$baseUrl/readMessages.php?userID=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> messagesJson = json.decode(response.body);
      List<Message> messages =
          messagesJson.map((json) => Message.fromJson(json)).toList();
      _messagesStreamController.add(messages);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<String?> getContactId() async {
    String? userId = await StorageService().getUserId();

    final response =
        await http.get(Uri.parse('$baseUrl/getContactId.php?userID=$userId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);

      return responseBody['contactedUserId'];
    } else {
      throw Exception('Failed to load messages');
    }
  }

  //poslání zprávy
  Future<void> sendMessage(String toUserId, String messageText) async {
    String? fromUserId = await StorageService().getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/sendMessage.php'),
      body: {
        'fromUserID': fromUserId,
        'toUserID': toUserId,
        'messageText': messageText,
      },
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Při posílání zprávy došlo k chybě');
    }
  }
}

final messageController = MessageController();
