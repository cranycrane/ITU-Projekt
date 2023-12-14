import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'flow.dart';
import 'diary_entries_loader.dart';
import 'diary_controller.dart';
import 'package:intl/intl.dart'; // Přidání pro formátování data
import 'get_code.dart';
import 'user_profile.dart';

class PsychoEntryPage extends StatefulWidget {
  final UserProfile client;
  final DateTime? selectedDay;

  const PsychoEntryPage({Key? key, this.selectedDay, required this.client})
      : super(key: key);

  @override
  PsychoEntryPageState createState() => PsychoEntryPageState();
}

class PsychoEntryPageState extends State<PsychoEntryPage> {
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
    return await loader.loadDiaryEntries(
        selectedDay, widget.client.userId.toString());
  }

  Future<bool> createEntry(FlowData record) async {
    try {
      // Zde předpokládáme, že `diaryController.createEntry(record)` vrací budoucnost (Future)
      await diaryController.createEntry(record);
      return true; // Úspěch
    } catch (e) {
      throw Exception('Chyba při vytváření záznamu: $e');
    }
  }

  Future<bool> deleteEntry() async {
    try {
      // Zde předpokládáme, že `diaryController.createEntry(record)` vrací budoucnost (Future)
      await diaryController.deleteEntry(selectedDate);
      return true; // Úspěch
    } catch (e) {
      throw Exception('Chyba při mazání záznamu: $e');
    }
  }

  void _changeDay(int days) {
    final DateTime newDate = selectedDate.add(Duration(days: days));

    // Check if the new date is in the future and if the selected date is not today
    if (newDate.isAfter(DateTime.now()) && selectedDate != DateTime.now()) {
      return; // Do nothing if trying to go into the future from a non-today date
    }
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
      _isDataLoaded = false;
      _recordFuture = _loadData(selectedDate);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SearchPage()));
        break;
      case 2:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PsychoUserPage()));
        break;
      case 3:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;

    String formattedDate =
        DateFormat('EEEE d.M.yyyy', 'cs_CZ').format(selectedDate).toUpperCase();

    return Scaffold(
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
                      if ((data?.record1.isEmpty ?? true) &&
                          (data?.record2.isEmpty ?? true) &&
                          (data?.record3.isEmpty ?? true)) {
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
                          decoration: InputDecoration(
                            labelText: 'První položka',
                            border: const OutlineInputBorder(),
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _secondController,
                          decoration: InputDecoration(
                            labelText: 'Druhá položka',
                            border: const OutlineInputBorder(),
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _thirdController,
                          decoration: InputDecoration(
                            labelText: 'Třetí položka',
                            border: const OutlineInputBorder(),
                            fillColor: Colors.grey[200],
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
                                'Jak bys ohodnotil svůj den?',
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
                                decoration: const InputDecoration(
                                  hintText: '/10',
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8.0),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
              icon: Icon(Icons.message,
                  color: _selectedIndex == 2 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(Icons.settings,
                  color: _selectedIndex == 3 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: keyboardHeight > 0
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.add),
              onPressed: () {
                // Akce pro FloatingActionButton
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}