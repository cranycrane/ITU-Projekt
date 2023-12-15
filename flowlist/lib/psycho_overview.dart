//import 'package:flowlist/calendar_screen.dart';
import 'package:flowlist/psycho_controller.dart';
import 'package:flutter/material.dart';
//import 'search_page.dart';
//import 'add_note.dart';
//import 'user_controller.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
//import 'package:permission_handler/permission_handler.dart';
import 'user_profile.dart';
import 'calendar_client.dart';
import 'settings_page.dart';
import 'package:intl/intl.dart';

class PsychoOverviewPage extends StatefulWidget {
  const PsychoOverviewPage({super.key});

  @override
  PsychoOverviewPageState createState() => PsychoOverviewPageState();
}

class PsychoOverviewPageState extends State<PsychoOverviewPage> {
  late Future<List<UserProfile>> pairedUsers;
  final TextEditingController _searchController =
      TextEditingController(); // Přidáno
  List<UserProfile> _allUsers = []; // Přidáno
  List<UserProfile> _filteredUsers = []; // Přidáno

  @override
  void initState() {
    super.initState();
    _initializeUsers();
  }

  void _initializeUsers() async {
    _allUsers = await psychoController
        .getPairedUsers(); // Předpokládá se, že psychoController má tuto funkci
    setState(() {
      _filteredUsers = _allUsers;
    });
  }

  void _performSearch(String query) {
    query = query.toLowerCase();
    List<UserProfile> filteredList = _allUsers.where((user) {
      // Předpokládá, že UserProfile má vlastnosti firstName a lastName
      String userName =
          '${user.firstName.toLowerCase()} ${user.lastName.toLowerCase()}';
      return userName.contains(query);
    }).toList();

    setState(() {
      _filteredUsers = filteredList;
    });
  }

  void _showDeleteConfirmationDialog(UserProfile user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Odebrat uživatele',
              style: TextStyle(color: Color(0xFFE50E2B))),
          content: Text(
              'Chcete opravdu odebrat uživatele ${user.firstName} ${user.lastName}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Zrušit', style: TextStyle(color: Colors.grey)),
              onPressed: () =>
                  Navigator.of(context).pop(), // Zavře dialogové okno
            ),
            TextButton(
              child: const Text('Odebrat',
                  style: TextStyle(color: Color(0xFFE50E2B))),
              onPressed: () async {
                try {
                  await psychoController.unPairWithClient(user);
                  setState(() {
                    _initializeUsers();
                  });
                  if (!context.mounted) return;

                  Navigator.of(context)
                      .pop(); // Zavře dialogové okno po potvrzení
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Párování bylo úspěšně zrušeno')));
                } catch (e) {
                  String errorMessage = e.toString().split('Exception: ')[1];

                  if (!context.mounted) return;

                  Navigator.of(context)
                      .pop(); // Zavře dialogové okno po potvrzení

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chyba: $errorMessage')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<UserProfile>> _getPairedUsers() async {
    List<UserProfile> records = await psychoController.getPairedUsers();
    return records;
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter =
        DateFormat('d. M. yyyy'); // Formát d. MMMM yyyy, jazyk čeština
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20), // Přidán SizedBox pro odsazení od vrchu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Vyhledat...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFFE50E2B)), // Červená barva pro lupu
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color:
                                Color(0xFFE50E2B)), // Červená barva pro křížek
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: _performSearch,
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                UserProfile user = _filteredUsers[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CalendarClientPage(client: user),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Zaoblené rohy karty
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEAEA),
                        //color: Colors.white, // Barva pozadí karty
                        borderRadius:
                            BorderRadius.circular(10), // Zaoblené rohy karty
                        border: Border.all(
                            color: Colors.grey.shade300), // Šedý rámeček
                      ),
                      child: Row(
                        children: <Widget>[
                          FutureBuilder<File?>(
                            future: psychoController.getUserPhoto(user),
                            builder: (BuildContext context,
                                AsyncSnapshot<File?> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors
                                      .grey[200], // Upravte podle vaší potřeby
                                  child: const CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError ||
                                  snapshot.data == null) {
                                return CircleAvatar(
                                  radius:
                                      30.0, // Upravte velikost podle vaší potřeby
                                  backgroundColor: Colors
                                      .grey[200], // Upravte podle vaší potřeby
                                  child: const Icon(Icons.person, size: 50.0),
                                );
                              } else {
                                return ClipOval(
                                  child: Image.file(
                                    snapshot.data!,
                                    width:
                                        60.0, // Upravte šířku podle vaší potřeby
                                    height:
                                        60.0, // Upravte výšku podle vaší potřeby
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${user.firstName} ${user.lastName}",
                                  style: const TextStyle(
                                      fontSize:
                                          18), // Upravte velikost písma podle vaší potřeby
                                ),
                                Text(
                                  user.lastRecordDate != null
                                      ? "Poslední příspěvek: ${formatDateTime(user.lastRecordDate!)}"
                                      : "Poslední příspěvek: Dosud žádný",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xFF6E6E6E)),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(user),
                            // Přidat logiku pro smazání uživatele
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              padding: const EdgeInsets.only(
                // Přidání paddingu na spodní část
                bottom: kBottomNavigationBarHeight +
                    16, // Výška spodní navigace plus další prostor
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            MainAxisAlignment.center, // Zarovnání tlačítek do prava
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              // Akce pro normální tlačítko
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Text(
                'MÓD BĚŽNÝ UŽIVATEL',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 19.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 55.0), // Mezera mezi tlačítky

          FloatingActionButton(
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

                  if (!mounted) return;

                  if (success) {
                    setState(() {
                      _initializeUsers();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Klient byl úspěšně spárován.")),
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
            backgroundColor: const Color(0xFFE50E2B),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // Zde můžete přidat funkce getPairedUsers a getUserPhoto...
}
