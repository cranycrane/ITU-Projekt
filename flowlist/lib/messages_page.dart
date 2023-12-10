import 'package:flutter/material.dart';
import 'message_controller.dart';
import 'message.dart';
import 'dart:async';

class MessagesPage extends StatefulWidget {
  final String toUserId;

  MessagesPage({Key? key, required this.toUserId}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  Timer? _pollingTimer;
  final TextEditingController _messageController = TextEditingController();
  late List<Message> messages;

  @override
  void initState() {
    super.initState();
    messageController.getMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      messageController
          .getMessages(); // Vaše existující metoda pro načítání zpráv
    });
  }

  void _sendMessage() async {
    final String messageText = _messageController.text;
    if (messageText.isEmpty) {
      return;
    }

    try {
      bool send =
          await messageController.sendMessage(widget.toUserId, messageText);
      if (send) {
        messageController.getMessages(); // Načtení nových zpráv po odeslání
        _messageController.clear();
      }
    } catch (e) {
      // Zachytávání výjimek
      throw Exception("Chyba pri odesilani zpravy");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Komunikace"), // Přidejte jméno a profilovou fotku uživatele
        leading: BackButton(), // Tlačítko pro návrat zpět
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Message>>(
                stream: messageController.messagesStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Message>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Chyba při načítání zpráv"));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text("Žádné zprávy"));
                  } else {
                    var messages = snapshot.data!;
                    return ListView.builder(
                      itemCount: messages.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        bool isSentByMe =
                            message.fromUserId.toString() != widget.toUserId;

                        return Align(
                          alignment: isSentByMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color:
                                  isSentByMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              message.messageText,
                              style: TextStyle(
                                  color:
                                      isSentByMe ? Colors.white : Colors.black),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  ;
                }),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _messageController,
              decoration: InputDecoration.collapsed(
                hintText: "Napište zprávu...",
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
