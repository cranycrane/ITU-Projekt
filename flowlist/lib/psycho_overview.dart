/// Aplikace Flow-List
/// FIT VUT, ITU - Tvorba uzivatelskych rozhrani
/// Autor: Vojtech Teichmann (xteich02)

import 'package:flowlist/psycho_controller.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'user_profile.dart';
import 'calendar_client.dart';
import 'settings_page.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';

// Definice třídy stavového widgetu pro stránku přehledu
class PsychoOverviewPage extends StatefulWidget {
  const PsychoOverviewPage({super.key});

  @override
  PsychoOverviewPageState createState() => PsychoOverviewPageState();
}

// Třída stavu pro stránku přehledu
class PsychoOverviewPageState extends State<PsychoOverviewPage> {
  // Deklarace proměnných pro uchování dat uživatelů
  late Future<List<UserProfile>> pairedUsers;
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _allUsers = [];
  List<UserProfile> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeUsers();
  }

// Načtení párovaných uživatelů a jejich nastavení do stavu
  void _initializeUsers() async {
    _allUsers = await psychoController.getPairedUsers();
    setState(() {
      _filteredUsers = _allUsers;
    });
  }

// Funkce pro vyhledávání uživatelů na základě zadaného dotazu
  void _performSearch(String query) {
    query = query.toLowerCase();
    List<UserProfile> filteredList = _allUsers.where((user) {
      String userName =
          '${user.firstName.toLowerCase()} ${user.lastName.toLowerCase()}';
      return userName.contains(query);
    }).toList();

    setState(() {
      _filteredUsers = filteredList;
    });
  }

  // Dialogové okno pro potvrzení odstranění uživatele
  void _showDeleteConfirmationDialog(UserProfile user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Odebrat uživatele',
              style: TextStyle(color: AppColors.red)),
          content: Text(
              'Chcete opravdu odebrat uživatele ${user.firstName} ${user.lastName}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Zrušit',
                  style: TextStyle(color: AppColors.middleGrey)),
              onPressed: () =>
                  Navigator.of(context).pop(), // Zavře dialogové okno
            ),
            TextButton(
              child:
                  const Text('Odebrat', style: TextStyle(color: AppColors.red)),
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

  // Formátování data a času
  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('d. M. yyyy');
    return formatter.format(dateTime);
  }

// Zde je vybudována celé uživatelské rozhraní stránky
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
                prefixIcon: const Icon(Icons.search, color: AppColors.red),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.red),
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
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CalendarClientPage(client: user),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.middleGrey),
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
                                  backgroundColor: Colors.grey[200],
                                  child: const CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError ||
                                  snapshot.data == null) {
                                return CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(Icons.person, size: 50.0),
                                );
                              } else {
                                user.imageFile = snapshot.data;
                                return ClipOval(
                                  child: Image.file(
                                    snapshot.data!,
                                    width: 60.0,
                                    height: 60.0,
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
                                  style: const TextStyle(fontSize: 18),
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
                                color: AppColors.darkGrey),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(user),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              padding: const EdgeInsets.only(
                bottom: kBottomNavigationBarHeight + 16,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.red,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: const BorderSide(color: AppColors.red),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Text(
                'MÓD BĚŽNÝ UŽIVATEL',
                style: TextStyle(
                  color: AppColors.red,
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
            backgroundColor: AppColors.red,
            child: const Icon(size: 35, Icons.add),
          ),
        ],
      ),
    );
  }
}
