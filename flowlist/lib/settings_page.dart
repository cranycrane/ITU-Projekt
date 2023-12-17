import 'package:flowlist/calendar_screen.dart';
import 'package:flowlist/notification_settings.dart';
import 'package:flowlist/welcome_page.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'add_note.dart';
import 'user_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'user_profile.dart';
import 'psycho_overview.dart';
import 'get_code.dart';
import 'psycho_controller.dart';
import 'statistics_page.dart';
import 'app_colors.dart';

class SettingsPage extends StatefulWidget {
  final int _selectedIndex = 3;

  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  UserProfile? user;

  Map<String, dynamic>? statistics;

  bool isLoading = true;
  bool? hasPsychologist = false;

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
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          user?.profileImage = croppedFile.path;
        });
        await userController.updateProfileImage(croppedFile.path);
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Uživatel musí stisknout tlačítko pro zavření dialogu
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Potvrzení',
            style: TextStyle(color: AppColors.red), // Nastavení barvy nadpisu
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Opravdu si přejete smazat svůj účet? Tato akce je nevratná.'),
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
              child: const Text(
                'Smazat',
                style: TextStyle(
                    color: AppColors
                        .red), // Nastavení barvy textu pro akci smazání
              ),
              onPressed: () async {
                bool success = await userController.deleteAccount();
                if (mounted && success) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WelcomePage(onlyLooking: false)));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUnpairPsychologistDialog() async {
    if (user!.hasPsychologist! == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nemáte spárovaného žádného psychologa",
            style: TextStyle(
              color: Colors.white, // Text color
            ),
          ),
          duration: Duration(seconds: 3), // Duration of the SnackBar display
        ),
      );
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Uživatel musí stisknout tlačítko pro zavření dialogu
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Potvrzení',
            style: TextStyle(color: AppColors.red), // Nastavení barvy nadpisu
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Opravdu si přejete zrušit spárování se svým psychologem? Tato akce je nevratná.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Nerušit',
                style: TextStyle(color: Colors.black), // Nastavení barvy textu
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Ano zrušit',
                style: TextStyle(
                    color: AppColors
                        .red), // Nastavení barvy textu pro akci smazání
              ),
              onPressed: () async {
                try {
                  await psychoController.unPairWithClient(user!);
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
      const Scaffold(
        body: Center(child: Text('Nepodařilo se načíst data uživatele')),
      );
    }
  }

  void _updateName(String name) async {
    // Tato funkce by měla zahrnovat logiku pro aktualizaci jména na serveru
    try {
      List<String> nameParts = name.split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts[1].length > 1 ? nameParts[1] : nameParts[2];
      await userController.updateUserName(firstName, lastName);
      setState(() {
        _isEditingName = false;
      });
      // Další akce po úspěšné aktualizaci (např. zobrazení zprávy)
    } catch (e) {
      // Zpracování chyby
      const Scaffold(
        body: Center(child: Text('Nepodařilo se aktualizovat jméno uživatele')),
      );
    }
  }

  void _onItemTapped(int index) {
    // Logika pro navigaci na různé stránky
    switch (index) {
      case 0:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;
      // Zde můžete přidat další navigaci pro Search, Notifications atd.
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SearchPage()));
        break;
      case 2:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PsychoUserPage()));
        break;
      case 3:
        // Pro tyto indexy není třeba žádná akce, protože jsme již na stránce nastavení
        break;
    }
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
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
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                CircleAvatar(
                  // Předpokládáme, že radius není nutný, pokud používáte pevnou velikost 80x80
                  backgroundColor: AppColors.lightGrey,
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
                            child: Image.file(File(user!.profileImage!),
                                width: 100, height: 100, fit: BoxFit.fill),
                          ),
                        ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _requestPermissions(); // Žádost o oprávnění
                    await _pickAndCropImage(); // Funkce pro výběr obrázku
                  },
                  child:
                      const Icon(Icons.camera_alt), // Ikonka pro výběr obrázku
                ),
                const SizedBox(height: 8),
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
                          : FittedBox(
                              fit: BoxFit
                                  .scaleDown, // Zajišťuje, že text se změstí do rodiče a zmenší se, pokud je to potřeba
                              child: Text(
                                _nameController.text,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                      _isEditingName
                          ? ElevatedButton(
                              onPressed: () =>
                                  _updateName(_nameController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: user!.hasPsychologist!
                                    ? AppColors.red
                                    : AppColors.middleGrey,
                              ),
                              child: Text(
                                'ULOŽIT',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (user!.hasPsychologist!
                                        ? Colors.white
                                        : Colors.black)),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _isEditingName =
                                      true; // Přepne stav na režim úpravy jména
                                });
                              },
                            )
                    ],
                  ),
                ),
                Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 3),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PsychoOverviewPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkGrey,
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width * 0.42,
                                    50)),
                            child: const Text(
                              'REŽIM PSYCHOLOGA',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Další prvky nastavení
                        //if (hasPsychologist!=null && hasPsychologist==true)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 6),
                          child: ElevatedButton(
                            onPressed: _showUnpairPsychologistDialog,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: user!.hasPsychologist!
                                    ? AppColors.red
                                    : AppColors.middleGrey,
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width * 0.42,
                                    50)),
                            child: Text(
                              'ZRUŠIT PÁROVÁNÍ\n S PSYCHOLOGEM',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (user!.hasPsychologist!
                                      ? Colors.white
                                      : Colors.black)),
                            ),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
                  child: ElevatedButton(
                    onPressed: _showDeleteAccountDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      // Zmenšení šířky tlačítka na 40% šířky obrazovky a výšky na 50
                      minimumSize: const Size(100, 50),
                      // Přidání vnitřního odsazení pro změnu rozměrů tlačítka
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'SMAZAT ÚČET',
                      style: TextStyle(
                        fontSize:
                            16, // Můžete upravit velikost písma, pokud je potřeba
                      ),
                    ),
                  ),
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: userController.getStatistics(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Chyba při načítání statistik',
                        style: TextStyle(
                          fontSize: 18, // Adjust the font size as needed
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else if (!snapshot.hasData) {
                      return const Text(
                        'Žádné statistiky k zobrazení',
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
                            _buildStatisticRow('Celkem dnů s Flow-lístkem:',
                                statistics!['totalDays'].toString()),
                            _buildStatisticRow('Celkem vyplněných dnů:',
                                statistics!['filledDays'].toString()),
                            _buildStatisticRow('Celkem nevyplněných dnů:',
                                statistics!['unfilledDays'].toString()),
                            _buildStatisticRow('Celkový počet slov:',
                                statistics!['totalWords'].toString()),
                            _buildStatisticRow('Průměrný počet slov na záznam:',
                                statistics!['averageWordsPerEntry'].toString()),
                            _buildStatisticRow('Nejvíce slov v záznamu',
                                statistics!['longestEntryLength'].toString()),
                            // Add more statistics as needed
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const StatisticsPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkGrey,
                                  minimumSize: const Size(100, 30),
                                ),
                                child: const Text(
                                  'DALŠÍ STATISTIKY',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height *
                0.045, // Nastavte podle potřeby pro umístění od horního okraje
            right: MediaQuery.of(context).size.width *
                0.05, // Nastavte podle potřeby pro umístění od pravého okraje
            child: IconButton(
              icon: const Icon(Icons.settings,
                  size: 35), // Velikost ikony nastavení
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsPage()),
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.045,
            right: MediaQuery.of(context).size.width *
                0.85, // Nastavte podle potřeby pro umístění od pravého okraje
            child: IconButton(
              icon: const Icon(Icons.question_mark,
                  size: 35), // Velikost ikony nastavení
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => WelcomePage(onlyLooking: true)),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.home,
                  color: widget._selectedIndex == 0
                      ? AppColors.red
                      : AppColors.middleGrey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.search,
                  color: widget._selectedIndex == 1
                      ? AppColors.red
                      : AppColors.middleGrey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), // Prostor pro Floating Action Button
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.message,
                  color: widget._selectedIndex == 2
                      ? AppColors.red
                      : AppColors.middleGrey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.person_outline,
                  color: widget._selectedIndex == 3
                      ? AppColors.red
                      : AppColors.middleGrey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        child: const Icon(size: 35, Icons.add),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewEntryPage()));
          // Implementace akce pro Floating Action Button
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
