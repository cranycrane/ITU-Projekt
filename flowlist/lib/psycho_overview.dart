import 'package:flowlist/calendar_screen.dart';
import 'package:flowlist/psycho_controller.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'add_note.dart';
import 'user_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'user_profile.dart';
import 'calendar_client.dart';

class PsychoOverviewPage extends StatefulWidget {
  @override
  _PsychoOverviewPageState createState() => _PsychoOverviewPageState();
}

class _PsychoOverviewPageState extends State<PsychoOverviewPage> {
  late Future<List<UserProfile>> pairedUsers;

  @override
  void initState() {
    super.initState();
    pairedUsers = _getPairedUsers(); // Předpokládá se, že máte tuto funkci
  }

  Future<List<UserProfile>> _getPairedUsers() async {
    List<UserProfile> records = await psychoController.getPairedUsers();
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Psycholog"),
        actions: [
          IconButton(
            icon: Icon(Icons.switch_account),
            onPressed: () {
              // Přepnout mód uživatele
            },
          ),
        ],
      ),
      body: FutureBuilder<List<UserProfile>>(
        future: pairedUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Chyba při načítání dat"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Žádní přidělení klienti"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                UserProfile user = snapshot.data![index];
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CalendarClientPage(
                              client:
                                  user), // Název a parametry stránky dle vaší aplikace
                        ),
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            // Obrázek uživatele
                            FutureBuilder<File?>(
                              future: psychoController.getUserPhoto(user),
                              builder: (BuildContext context,
                                  AsyncSnapshot<File?> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircleAvatar(
                                    radius: 50.0,
                                    child: CircularProgressIndicator(),
                                    backgroundColor: Colors.grey[200],
                                  );
                                } else if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  return CircleAvatar(
                                    radius: 50.0,
                                    child: Icon(Icons.person, size: 100.0),
                                    backgroundColor: Colors.grey[200],
                                  );
                                } else {
                                  return SizedBox(
                                    width: 70.0,
                                    height: 70.0,
                                    child: ClipOval(
                                      child: Image.file(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(
                                width:
                                    16.0), // Vytvoří prostor mezi obrázkem a textem
                            // Textová část
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${user.firstName} ${user.lastName}",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  Text(
                                      "Poslední příspěvek: 5.12.2023"), // Dummy data
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Zobrazení dialogového okna pro zadání párovacího kódu
          String? pairingCode = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              TextEditingController pairingCodeController =
                  TextEditingController();
              return AlertDialog(
                title: const Text('Zadejte párovací kód klienta'),
                content: TextField(
                  controller: pairingCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Párovací kód',
                  ),
                  keyboardType: TextInputType.number,
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Zrušit'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text('Potvrdit'),
                    onPressed: () {
                      Navigator.of(context).pop(pairingCodeController.text);
                    },
                  ),
                ],
              );
            },
          );

          // Zpracování výsledku
          if (pairingCode != null && pairingCode.isNotEmpty) {
            try {
              final success =
                  await psychoController.pairWithClient(pairingCode);
              if (success) {
                setState(() {
                  pairedUsers = _getPairedUsers();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Klient byl úspěšně spárován.")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          "Nepodařilo se najít uživatele s tímto párovacím kódem.")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Chyba: ${e.toString()}")),
              );
            }
          }
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  // Zde můžete přidat funkce getPairedUsers a getUserPhoto...
}
