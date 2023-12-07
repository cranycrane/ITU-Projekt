import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'flow.dart';
import 'diary_entries_loader.dart';
import 'diary_controller.dart';
import 'package:intl/intl.dart'; // Přidání pro formátování data

class NewEntryPage extends StatefulWidget {
  final DateTime? selectedDay;

  NewEntryPage({Key? key, this.selectedDay}) : super(key: key);

  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

/*
TODO: Hlasku uzivateli po uspesnem pridani
*/
class _NewEntryPageState extends State<NewEntryPage> {
  late DateTime selectedDate; // Přidáno pro sledování vybraného data
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  bool _isDataLoaded = false;
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
    return await loader.loadDiaryEntries(selectedDay);
  }

  Future<bool> createEntry(FlowData record) async {
    try {
      // Zde předpokládáme, že `diaryController.createEntry(record)` vrací budoucnost (Future)
      await diaryController.createEntry(record);
      return true; // Úspěch
    } catch (e) {
      print('Chyba při vytváření záznamu: $e');
      return false; // Neúspěch
    }
  }

  void _changeDay(int days) {
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
            .push(MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 2:
      case 3:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
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
              icon: Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => _changeDay(-1),
            ),
            Text(
              formattedDate,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: Colors.black),
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
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Došlo k chybě při načítání dat');
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
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // Přidáno pro zarovnání
                      children: <Widget>[
                        SizedBox(height: 10),
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
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
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
                                decoration: InputDecoration(
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
                        SizedBox(height: 16),
                        Row(
                          // Tlačítka vedle sebe s mezerou
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Akce pro smazání dat
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.grey, // Barva tlačítka SMAZAT
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // Bez zaoblení
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text('SMAZAT'),
                              ),
                            ),
                            SizedBox(width: 8), // Mezera mezi tlačítky
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  FlowData record = FlowData(
                                      record1: _firstController.text,
                                      record2: _secondController.text,
                                      record3: _thirdController.text,
                                      score:
                                          int.tryParse(_ratingController.text),
                                      day: selectedDate);

                                  bool success = await createEntry(record);
                                  String message = success
                                      ? 'Záznam byl úspěšně přidán'
                                      : 'Přidání záznamu se nezdařilo';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)));

                                  if (success) {
                                    _onItemTapped(0);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red, // Barva tlačítka ULOŽIT
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text('ULOŽIT'),
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
              child: Icon(Icons.add),
              onPressed: () {
                // Akce pro FloatingActionButton
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
