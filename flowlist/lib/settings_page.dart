import 'package:flowlist/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'add_note.dart';
import 'user_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'user_profile.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserProfile? user;

  Map<String, dynamic>? statistics;

  bool isLoading = true;

  int _selectedIndex = 3; // Index pro nastavení stránky

  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _pickAndCropImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: const Color.fromARGB(255, 255, 91, 73),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          user?.profileImage = File(croppedFile.path);
        });
        await userController.updateProfileImage(croppedFile.path);
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Uživatel musí stisknout tlačítko pro zavření dialogu
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Potvrzení',
          style: TextStyle(color: Colors.red), // Nastavení barvy nadpisu
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Opravdu si přejete smazat svůj účet? Tato akce je nevratná.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Zrušit',
              style: TextStyle(color: Colors.black), // Nastavení barvy textu
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Smazat',
              style: TextStyle(color: Colors.red), // Nastavení barvy textu pro akci smazání
            ),
            onPressed: () {
              // Zde by měla být logika pro smazání účtu
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  void _loadUserData() async {
    try {
      user = await userController
          .getUserData(); // Předpokládáme, že getUserName je ve vašem controlleru

      setState(() {
        isLoading = false;
        _nameController.text = '${user?.firstName} ${user?.lastName}';
      });
    } catch (e) {
      // Zpracování případných chyb při získávání jména
      print('Chyba při získávání jména uživatele: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateName(String name) async {
    // Tato funkce by měla zahrnovat logiku pro aktualizaci jména na serveru
    try {
      await userController.updateUserName(name);
      setState(() {
        _isEditingName = false;
      });
      // Další akce po úspěšné aktualizaci (např. zobrazení zprávy)
    } catch (e) {
      // Zpracování chyby
      print('Chyba při aktualizaci jména: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Logika pro navigaci na různé stránky
    switch (index) {
      case 0:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;
      // Zde můžete přidat další navigaci pro Search, Notifications atd.
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 2:
      case 3:
        // Pro tyto indexy není třeba žádná akce, protože jsme již na stránce nastavení
        break;
    }
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Nepodařilo se načíst data uživatele')),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            CircleAvatar(
              // Předpokládáme, že radius není nutný, pokud používáte pevnou velikost 80x80
              backgroundColor: Colors.grey[200],
              //backgroundImage: user?.profileImage != null
              //    ? FileImage(user.profileImage)
              //    : null,
              radius: 50,
              child: user?.profileImage == null
                  ? const Icon(Icons.person, size: 100)
                  : SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipOval(
                        child: Image.file(user!.profileImage!,
                            width: 100, height: 100, fit: BoxFit.fill),
                      ),
                    ),
            ),

            GestureDetector(
              onTap: () async {
                await _requestPermissions(); // Žádost o oprávnění
                await _pickAndCropImage(); // Funkce pro výběr obrázku
              },
              child: const Icon(Icons.camera_alt), // Ikonka pro výběr obrázku
            ),

            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isEditingName
                      ? Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            onSubmitted:
                                _updateName, // Volání funkce pro aktualizaci jména
                          ),
                        )
                      : Text(
                          _nameController.text,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isEditingName =
                            true; // Přepne stav na režim úpravy jména
                      });
                    },
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: false,
              onChanged: (bool value) {
                // Implementace přepnutí Dark Mode
              },
            ),
            // Další prvky nastavení
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton(
                onPressed: _showDeleteAccountDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity,
                      50), // Nastavení šířky na šířku obrazovky a výšku na 50
                ),
                child: const Text('SMAZAT ÚČET'),
              ),
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: userController.getStatistics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Chyba při načítání statistik',
                      style: TextStyle(
                      fontSize: 18, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                    ),
                   );
                } else if (!snapshot.hasData) {
                  return const Text('Žádné statistiky k zobrazení',
                      style: TextStyle(
                      fontSize: 18, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                     ),
                   );
                } else {
                  statistics = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildStatisticRow('Celkem dnů s Flow-lístkem:', statistics!['totalDays'].toString()),
                _buildStatisticRow('Celkem vyplněných dnů:', statistics!['filledDays'].toString()),
                _buildStatisticRow('Celkem nevyplněných dnů:', statistics!['unfilledDays'].toString()),
                _buildStatisticRow('Celkový počet slov:', statistics!['totalWords'].toString()),
                _buildStatisticRow('Průměrný počet slov na záznam:', statistics!['averageWordsPerEntry'].toString()),
                _buildStatisticRow('Nejvíce slov v záznamu', statistics!['longestEntryLength'].toString()),
                // Add more statistics as needed
              ],
            ),
          );
        }
      },
    ),
  ],
),
  ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.search,
                  color: _selectedIndex == 1 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), // Prostor pro Floating Action Button
            IconButton(
              icon: Icon(Icons.notifications_none,
                  color: _selectedIndex == 2 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(Icons.person_outline,
                  color: _selectedIndex == 3 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => NewEntryPage()));
          // Implementace akce pro Floating Action Button
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
