import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'settings_page.dart';
import 'add_note.dart';
import 'flow.dart';
import 'diary_controller.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _selectedIndex = 1; // Index pro vyhledávací stránku
  TextEditingController _searchController = TextEditingController();
  List<FlowData> _allRecords = []; // List pro uložení všech záznamů
  List<FlowData> _filteredRecords =
      []; // Filtr pro zobrazení výsledků vyhledávání

  @override
  void initState() {
    super.initState();
    _fetchAllRecords();
  }

  void _fetchAllRecords() async {
    List<FlowData> records = await diaryController.readEntries();
    setState(() {
      _allRecords = records;
    });
  }

  void _performSearch(String query) async {
    List<FlowData> filteredRecords = await _filterEntries(query);
    setState(() {
      _filteredRecords = filteredRecords;
    });
  }

  Future<List<FlowData>> _filterEntries(String query) async {
    // Převedení hledaného řetězce na malá písmena
    String lowerCaseQuery = query.toLowerCase();

    // Filtrování záznamů
    return _allRecords.where((entry) {
      // Převedení obsahu záznamů na malá písmena pro porovnání
      bool matchesRecord1 =
          entry.record1.toLowerCase().contains(lowerCaseQuery);
      bool matchesRecord2 =
          entry.record2.toLowerCase().contains(lowerCaseQuery);
      bool matchesRecord3 =
          entry.record3.toLowerCase().contains(lowerCaseQuery);

      return matchesRecord1 || matchesRecord2 || matchesRecord3;
    }).toList();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => CalendarPage()));
          break;
        case 1:
          // Již jsme na vyhledávací stránce, není potřeba akce
          break;
        case 2:
          // Implementace přechodu na stránku s oznámeními, pokud máte
          break;
        case 3:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SettingsPage()));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ListView(
        children: <Widget>[
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
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                // Implementace pro vyhledávání záznamů
                _performSearch(value);
              },
              onSubmitted: (value) {},
            ),
          ),
          _buildSearchResults(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
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
            SizedBox(width: 48), // Prostor pro Floating Action Button
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
        child: Icon(Icons.add),
        onPressed: () {
          // Získání aktuálního data
          DateTime currentDate = DateTime.now();

          // Navigace na NewEntryPage s aktuálním datem
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewEntryPage(selectedDay: currentDate),
            ),
          );
          // Implementace akce pro Floating Action Button
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return Center(child: Text("Zadejte hledaný výraz."));
    }
    if (_filteredRecords.isEmpty) {
      return Center(child: Text("Žádné výsledky vyhledávání"));
    }

    return SingleChildScrollView(
      child: Column(
        children: _filteredRecords.map((entry) {
          return ListTile(
            title: Text(
              DateFormat('dd.MM.yyyy').format(entry.day),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                Text("${entry.record1}\n${entry.record2}\n${entry.record3}"),
          );
        }).toList(),
      ),
    );
  }
}
