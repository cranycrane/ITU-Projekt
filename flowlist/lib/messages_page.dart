/// Aplikace Flow-list
/// FIT VUT, ITU - Tvorba uživatelských rozhraní
/// Autor: Doubravka Šimůnková (xsimun05)

import 'package:flowlist/user_profile.dart';
import 'package:flutter/material.dart';
import 'message_controller.dart';
import 'message.dart';
import 'dart:async';
import 'user_controller.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'app_colors.dart';

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

  late UserProfile contactedUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    messageController.getMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    try {
      contactedUser = await userController.getUserData(widget
          .toUserId); 

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      const Scaffold(
        body: Center(child: Text('Nepodařilo se načíst data uživatele')),
      );
    }
  }

  //načtení zpráv každách 5 sekund
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        isFirstLoad = false;
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
      formatter = DateFormat('dd.MM. HH:mm'); //Datum bez roku, pokud je rok stejný
    } else {
      formatter = DateFormat('dd.MM. yyyy HH:mm'); // Celé datum, pokud se rok liší
    }

    return formatter.format(timestamp);
  }

  //odeslání zprávy
  void _sendMessage() async {
    final String messageText = _messageController.text;
    //pokud je text zprávy prázdný nic se nestane
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
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 85,
          title: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(
                horizontal: 3.0, vertical: 3.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.all(Radius.circular(20.0)), 
            ),
            //zobrazení profilové fotky a jména toho s kým si píši
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 60, 
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : contactedUser.profileImage == null
                            ? const Icon(Icons.person, size: 60)
                            : Image.file(
                                File(contactedUser.profileImage!),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                Expanded(
                  child: isLoading
                    ? const Text(
                      "Načítání...",
                      style: const TextStyle(
                              color: Colors.black, fontSize: 20)
                      )
                    : Text(
                        "${contactedUser.firstName} ${contactedUser.lastName}",
                        style: const TextStyle(
                            color: Colors.black, fontSize: 20),
                      )
                ),
              ],
            ),
          ),
          //šipka pro návrat zpět
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.darkGrey,
            iconSize: 40, 
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              //zobrazení zpráv
              child: StreamBuilder<List<Message>>(
                  stream: messageController.messagesStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Message>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text("Chyba při načítání zpráv"));
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text("Žádné zprávy"));
                    } else {
                      var messages = snapshot.data!;
                      return ListView.builder(
                        itemCount: messages.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          //je správa odeslána mnou?
                          bool isSentByMe =
                              message.fromUserId.toString() != widget.toUserId;
                          String formattedTime =
                              formatTimestamp(message.timestamp);

                          return Align(
                              alignment: isSentByMe
                                  ? Alignment.centerRight //správy odeslané mnou
                                  : Alignment.centerLeft, //přijaté zprávy
                              child: Column(
                                  crossAxisAlignment: isSentByMe
                                      ? CrossAxisAlignment.end //správy odeslané mnou
                                      : CrossAxisAlignment.start, //přijaté zprávy
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal:
                                              15), 
                                      child: Text(
                                        formattedTime, //čas odeslání/přijetí zprávy
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.middleGrey),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isSentByMe) // Zobrazení avatara odesílatele, pouze pro přijaté zprávy
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 3.0, left: 15.0),
                                            child: CircleAvatar(
                                              radius:
                                                  15, 
                                              backgroundColor: Colors.grey[200],
                                              child: ClipOval(
                                                child: isLoading
                                                    ? const CircularProgressIndicator()
                                                    : contactedUser
                                                                .profileImage ==
                                                            null
                                                        ? const Icon(
                                                            Icons.person,
                                                            size: 30)
                                                        : Image.file(
                                                            File(contactedUser
                                                                .profileImage!),
                                                            width: 30,
                                                            height: 30,
                                                            fit: BoxFit.cover,
                                                          ),
                                              ),
                                            ),
                                          ),
                                        //vzhled zprávy
                                        Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 330.0),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: isSentByMe
                                                ? AppColors.red //odeslané
                                                : AppColors.middleGrey, //přijaté
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
                                                  16, 
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
            const SizedBox(height: 5),
            _buildMessageInputField(),
          ],
        ),
      ),
    );
  }

  //okno pro psaní zpráv
  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                    vertical: 10.0), 
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 3.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                      width: 2.0, color: AppColors.red), 
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.send),
            color: AppColors.darkGrey,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
