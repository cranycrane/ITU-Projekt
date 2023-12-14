import 'package:flowlist/user_profile.dart';
import 'package:flutter/material.dart';
import 'message_controller.dart';
import 'message.dart';
import 'dart:async';
import 'user_controller.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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
  bool isFirstLoad = true;

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
      setState(() {
        isFirstLoad = false; // Po prvním načtení již není první načtení
      });
      messageController.getMessages();
    });
  }

  String formatTimestamp(String timestampStr) {
    DateTime timestamp = DateTime.parse(timestampStr);
    DateTime now = DateTime.now();
    DateFormat formatter;

    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      formatter = DateFormat('HH:mm'); // Pouze hodiny a minuty pro dnešní datum
    } else if (timestamp.year == now.year) {
      formatter = DateFormat('dd.MM. HH:mm');
    } else {
      formatter = DateFormat('dd.MM. yyyy HH:mm'); // Celé datum, pokud se liší
    }

    return formatter.format(timestamp);
  }

  void _sendMessage() async {
    final String messageText = _messageController.text;
    if (messageText.isEmpty) {
      return;
    }

    try {
      await messageController.sendMessage(widget.toUserId, messageText);
      messageController.getMessages(); // Načtení nových zpráv po odeslání
      _messageController.clear();
    } catch (e) {
      if (!context.mounted) return;
      String errorMessage = e.toString().split('Exception: ')[1];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Chyba: $errorMessage')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Odstranění fokusu z jakéhokoli aktuálně zaměřeného widgetu
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 85,
          title: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(
                horizontal: 3.0, vertical: 3.0), // Vnější odsazení pro obdélník
            decoration: BoxDecoration(
              color: Colors.white,
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
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        isFirstLoad) {
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
                Expanded(
                  child: FutureBuilder<UserProfile?>(
                    future: userController
                        .getUserData(widget.toUserId), // Získání dat uživatele
                    builder: (BuildContext context,
                        AsyncSnapshot<UserProfile?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          isFirstLoad) {
                        return Text("Načítání..."); // Zobrazit při načítání
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return Text(
                            "Uživatel"); // Záložní text, pokud dojde k chybě nebo data nejsou dostupná
                      } else {
                        UserProfile userProfile = snapshot.data!;
                        return Text(
                          "${userProfile.firstName} ${userProfile.lastName}", // Jméno uživatele
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20),
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
            color: Color(0xFF61646B),
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
                          String formattedTime =
                              formatTimestamp(message.timestamp);

                          return Align(
                              alignment: isSentByMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Column(
                                  crossAxisAlignment: isSentByMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal:
                                              15), // Stejné horizontální odsazení jako u kontejneru zprávy
                                      child: Text(
                                        formattedTime,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isSentByMe) // Zobrazujeme avatara pouze pro přijaté zprávy
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 3.0, left: 15.0),
                                            child: FutureBuilder<UserProfile?>(
                                              future:
                                                  userController.getUserData(
                                                      message.fromUserId
                                                          .toString()),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                        ConnectionState
                                                            .waiting &&
                                                    isFirstLoad) {
                                                  return CircularProgressIndicator(); // Při načítání
                                                } else if (snapshot.hasError ||
                                                    snapshot.data == null) {
                                                  return Icon(Icons.person,
                                                      size:
                                                          30); // Výchozí ikona
                                                } else {
                                                  UserProfile userProfile =
                                                      snapshot.data!;
                                                  return CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    backgroundImage: userProfile
                                                                .profileImage !=
                                                            null
                                                        ? FileImage(File(
                                                            userProfile
                                                                .profileImage!))
                                                        : null,
                                                    child: userProfile
                                                                .profileImage ==
                                                            null
                                                        ? Icon(Icons.person,
                                                            size: 30)
                                                        : null,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 330.0),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: isSentByMe
                                                ? const Color(0xFFE50E2B)
                                                : Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            message.messageText,
                                            style: TextStyle(
                                              color: isSentByMe
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize:
                                                  16, // Nastavení velikosti písma
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]));
                        },
                      );
                    }
                  }),
            ),
            SizedBox(height: 5),
            _buildMessageInputField(),
          ],
        ),
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
            color: Color(0xFF61646B),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
