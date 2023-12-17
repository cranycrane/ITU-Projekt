/// Aplikace Flow-List
/// FIT VUT, ITU - Tvorba uzivatelskych rozhrani
/// Autor: Vojtech Teichmann (xteich02)

import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'flow.dart';
import 'diary_entries_loader.dart';
import 'diary_controller.dart';
import 'package:intl/intl.dart';
import 'get_code.dart';
import 'app_colors.dart';

// Definice třídy stavového widgetu pro stránku nového záznamu
class NewEntryPage extends StatefulWidget {
  final DateTime? selectedDay;

  const NewEntryPage({Key? key, this.selectedDay}) : super(key: key);

  @override
  NewEntryPageState createState() => NewEntryPageState();
}

// Třída stavu pro stránku nového záznamu
class NewEntryPageState extends State<NewEntryPage> {
  late DateTime selectedDate; // Přidáno pro sledování vybraného data
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  bool _isDataLoaded = false;
  bool dataFromBackend = true;
  late Future<FlowData?> _recordFuture;

  int _selectedIndex = -1; // Index pro navigaci v BottomAppBar

  @override
  void initState() {
    super.initState();
    // Inicializace a načtení dat při vytvoření stránky
    selectedDate = widget.selectedDay ?? DateTime.now();
    _recordFuture = _loadData(selectedDate);
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  // Funkce pro načtení záznamů z deníku
  Future<FlowData?> _loadData(DateTime selectedDay) async {
    DiaryEntriesLoader loader = DiaryEntriesLoader(diaryController);
    return await loader.loadDiaryEntries(selectedDay);
  }

  // Funkce pro vytvoření záznamu
  Future<bool> createEntry(FlowData record) async {
    try {
      await diaryController.createEntry(record);
      return true;
    } catch (e) {
      throw Exception('Chyba: $e');
    }
  }

  // Funkce pro vymazání záznamu
  Future<bool> deleteEntry() async {
    try {
      await diaryController.deleteEntry(selectedDate);
      return true;
    } catch (e) {
      throw Exception('Chyba při mazání záznamu: $e');
    }
  }

  void _changeDay(int days) {
    final DateTime newDate = selectedDate.add(Duration(days: days));

    if (newDate.isAfter(DateTime.now()) && selectedDate != DateTime.now()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nelze pracovat se dny v budoucnosti",
            style: TextStyle(
              color: Colors.black, 
            ),
          ),
          duration: Duration(seconds: 3), 
          backgroundColor: AppColors.lightGrey,
        ),
      );
      return;
    }
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
      _isDataLoaded = false;
      _recordFuture = _loadData(selectedDate);
    });
  }

 // Implementace navigace na základě vybrané položky v navigační liště
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;
      case 1:
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => const SearchPage()));
        break;
      case 2:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PsychoUserPage()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
     // Tělo widgetu s konstrukcí uživatelského rozhraní
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    String formattedDate =
        DateFormat('EEEE d.M.yyyy', 'cs_CZ').format(selectedDate).toUpperCase();

    return Scaffold(
      // Nastavení vzhledu a funkcí AppBar, těla stránky a navigační lišty
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => _changeDay(-1),
            ),
            Text(
              formattedDate,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.black),
              onPressed: () => _changeDay(1),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IntrinsicHeight(
              // Tento widget zajistí, že obsah bude mít minimální výšku
              child: FutureBuilder<FlowData?>(
                future: _recordFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Došlo k chybě při načítání dat');
                  } else {
                    // Aktualizace textových polí podle načtených dat
                    if (!_isDataLoaded && snapshot.data != null) {
                      final data = snapshot.data;
                      _firstController.text = data?.record1 ?? '';
                      _secondController.text = data?.record2 ?? '';
                      _thirdController.text = data?.record3 ?? '';
                      _ratingController.text =
                          data?.score == -1 ? '' : data!.score!.toString();
                      _isDataLoaded = true;
                      if ((data!.record1.isEmpty) &&
                          (data.record2.isEmpty) &&
                          (data.record3.isEmpty) &&
                          (data.score == -1)) {
                        dataFromBackend = false;
                      }
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // Přidáno pro zarovnání
                      children: <Widget>[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _firstController,
                          cursorColor: AppColors.red,
                          cursorWidth: 2,
                          decoration: InputDecoration(
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                            labelText: 'První dobrá věc...',
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 4),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: AppColors.red, 
                                width: 2.0,
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _secondController,
                          cursorColor: AppColors.red,
                          cursorWidth: 2,
                          decoration: InputDecoration(
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                            labelText: 'Druhá dobrá věc...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: AppColors.red, 
                                width: 2.0, 
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _thirdController,
                          cursorColor: AppColors.red,
                          cursorWidth: 2,
                          decoration: InputDecoration(
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                            labelText: 'Třetí dobrá věc...',
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(width: 15),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: AppColors.red, 
                                width: 2.0, 
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Flexible(
                              child: Text(
                                'Jak bys ohodnotil/a svůj den?',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width:
                                  80, // Nastavení pevné šířky pro textové pole
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: _ratingController,
                                cursorColor: AppColors.red,
                                cursorWidth: 2,
                                decoration: InputDecoration(
                                  floatingLabelStyle:
                                      const TextStyle(color: Colors.black),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: AppColors.red, 
                                      width: 2.0, 
                                    ),
                                  ),
                                  hintText: '/10',
                                  border: const OutlineInputBorder(),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          // Tlačítka vedle sebe s mezerou
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Zobrazení dialogového okna pro potvrzení
                                  print(dataFromBackend);
                                  if (!dataFromBackend) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Nelze smazat záznam, který nebyl uložen!",
                                          style: TextStyle(
                                            color: Colors.black, 
                                          ),
                                        ),
                                        duration: Duration(
                                            seconds:
                                                3), 
                                        backgroundColor: AppColors.lightGrey,
                                      ),
                                    );
                                    return;
                                  }
                                  final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Potvrzení', style: TextStyle(color: AppColors.red)),
                                            content: const Text(
                                                'Opravdu chcete záznam smazat?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text('NE', style: TextStyle(color: AppColors.darkGrey)),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text('ANO', style: TextStyle(color: AppColors.red)),
                                              ),
                                            ],
                                          );
                                        },
                                      ) ??
                                      false; // Pokud se dialog zavře bez výběru, vrátí se false

                                  if (confirmed) {
                                    // Uložení kontextu před asynchronní operací
                                    final BuildContext savedContext = context;

                                    // Provádění akce smazání, pokud uživatel potvrdí
                                    bool success = await deleteEntry();
                                    String message = success
                                        ? 'Záznam byl úspěšně smazán'
                                        : 'Smazání záznamu se nezdařilo';

                                    // Použití uloženého kontextu
                                    if (mounted) {
                                      // Kontrola, zda je stále kontext aktivní
                                      ScaffoldMessenger.of(savedContext)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            message,
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          duration: const Duration(
                                              seconds:
                                                  3), 
                                          backgroundColor: AppColors.lightGrey,
                                        ),
                                      );
                                    }

                                    if (success) {
                                      _onItemTapped(0);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.darkGrey, 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), 
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('SMAZAT'),
                              ),
                            ),

                            const SizedBox(width: 8), // Mezera mezi tlačítky
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Uložení kontextu před asynchronní operací
                                  final BuildContext savedContext = context;

                                  FlowData record = FlowData(
                                      record1: _firstController.text,
                                      record2: _secondController.text,
                                      record3: _thirdController.text,
                                      score:
                                          int.tryParse(_ratingController.text),
                                      day: selectedDate);

                                  try {
                                    
                                    await diaryController.createEntry(record);
                                    if (mounted) {
                                      ScaffoldMessenger.of(savedContext)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Záznam byl úspěšně přidán",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          duration: Duration(
                                              seconds:
                                                  3), 
                                          backgroundColor: AppColors.lightGrey,
                                        ),
                                      );
                                    }
                                    _onItemTapped(0);
                                  } catch (e) {
                                    if (mounted) {
                                      String errorMessage =
                                          e.toString().split('Exception: ')[1];
                                      ScaffoldMessenger.of(savedContext)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Chyba: $errorMessage',
                                            style: const TextStyle(
                                              color: Colors.black, 
                                            ),
                                          ),
                                          duration: const Duration(
                                              seconds:
                                                  3), 
                                          backgroundColor: AppColors.lightGrey,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.red, 
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('ULOŽIT'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
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
              iconSize: 35,
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0 ? AppColors.red : AppColors.middleGrey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.search,
                  color: _selectedIndex == 1 ? AppColors.red : AppColors.middleGrey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), 
            IconButton(
              iconSize: 35,
              icon: const Icon(Icons.message,
                  color: AppColors.middleGrey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.person_outline,
                  color: _selectedIndex == 3 ? AppColors.red : AppColors.middleGrey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: isKeyboardOpen
        ? Container() // Pokud je klávesnice otevřená, nezobrazujeme FAB
        : FloatingActionButton(
            backgroundColor: AppColors.red,
            child: const Icon(size: 35, Icons.add),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const NewEntryPage()));
            },
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
