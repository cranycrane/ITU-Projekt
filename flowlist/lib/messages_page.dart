import 'package:flowlist/user_profile.dart';
import 'package:flutter/material.dart';
import 'message_controller.dart';
import 'message.dart';
import 'dart:async';
import 'user_controller.dart';
import 'dart:io';

class MessagesPage extends StatefulWidget {
  final String toUserId;

  const MessagesPage({Key? key, required this.toUserId}) : super(key: key);

  @override
  MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
  Timer? _pollingTimer;
  final TextEditingController _messageController = TextEditingController();
  late List<Message> messages;

  bool isLoading = true;

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
        backgroundColor: Colors.white,
        toolbarHeight: 70,
        title: Container(
          height: 60,
          padding: const EdgeInsets.all(5.0), // Vnější odsazení pro obdélník
          decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9),
            borderRadius:
                BorderRadius.all(Radius.circular(20.0)), // Zaoblené rohy
          ),
          child: Row(
            children: <Widget>[
              FutureBuilder<UserProfile?>(
                future: userController.getUserData(widget.toUserId),
                builder: (BuildContext context,
                    AsyncSnapshot<UserProfile?> snapshot) {
                  Widget avatar;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    avatar = CircularProgressIndicator();
                  } else if (snapshot.hasError || snapshot.data == null) {
                    avatar = Icon(Icons.person, size: 50);
                  } else {
                    UserProfile userProfile = snapshot.data!;
                    avatar = userProfile.profileImage == null
                        ? Icon(Icons.person, size: 50)
                        : Image.file(
                            File(userProfile.profileImage!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          );
                  }
                  return CircleAvatar(
                    radius: 50, // Zvětšení velikosti CircleAvatar
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: avatar,
                    ),
                  );
                },
              ),
              SizedBox(width: 0.0), // Prostor mezi obrázkem a textem
              Expanded(
                child: FutureBuilder<UserProfile?>(
                  future: userController
                      .getUserData(widget.toUserId), // Získání dat uživatele
                  builder: (BuildContext context,
                      AsyncSnapshot<UserProfile?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Načítání..."); // Zobrazit při načítání
                    } else if (snapshot.hasError || snapshot.data == null) {
                      return Text(
                          "Uživatel"); // Záložní text, pokud dojde k chybě nebo data nejsou dostupná
                    } else {
                      UserProfile userProfile = snapshot.data!;
                      return Text(
                        "${userProfile.firstName} ${userProfile.lastName}", // Jméno uživatele
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.grey,
          iconSize: 40, // Zvětšení velikosti ikony
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                              color: isSentByMe
                                  ? const Color(0xFF61646B)
                                  : Colors.grey[300],
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
                }),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Napište zprávu...",
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10.0), // Úprava vertikálního paddingu
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 3.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                      width: 2.0, color: Color(0xFFE50E2B)), // Barva zvýraznění
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
