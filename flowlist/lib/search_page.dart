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
                prefixIcon: Icon(Icons.search, color: Color(0xFFE50E2B)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Color(0xFFE50E2B)),
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
              icon: Icon(Icons.home, // color: Color(0xFFE50E2B)
                  color: _selectedIndex == 0 ? Color(0xFFE50E2B) : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.search,
                  color: _selectedIndex == 1 ? Color(0xFFE50E2B) : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            SizedBox(width: 48), // Prostor pro Floating Action Button
            IconButton(
              icon: Icon(Icons.notifications_none,
                  color: _selectedIndex == 2 ? Color(0xFFE50E2B) : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(Icons.person_outline,
                  color: _selectedIndex == 3 ? Color(0xFFE50E2B) : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE50E2B),
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

  String searchQuery = _searchController.text.toLowerCase();

  List<Widget> searchResultsWidgets = [];
  _filteredRecords.forEach((entry) {
    // Kontrola, zda některý záznam obsahuje vyhledávané slovo
    bool containsInRecord1 = entry.record1.toLowerCase().contains(searchQuery);
    bool containsInRecord2 = entry.record2.toLowerCase().contains(searchQuery);
    bool containsInRecord3 = entry.record3.toLowerCase().contains(searchQuery);

        if (containsInRecord1 || containsInRecord2 || containsInRecord3) {
      searchResultsWidgets.add(
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewEntryPage(selectedDay: entry.day),
              ));
            },
            child: ListTile(
              title: Text(
                DateFormat('dd.MM.yyyy').format(entry.day),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (containsInRecord1) _highlightSearchTerm(entry.record1, searchQuery),
                  if (containsInRecord2) _highlightSearchTerm(entry.record2, searchQuery),
                  if (containsInRecord3) _highlightSearchTerm(entry.record3, searchQuery),
                ],
              ),
            ),
          ),
        ),
      );
    }
  });

  return SingleChildScrollView(
    child: Column(children: searchResultsWidgets),
  );
}


// Helper method to highlight search term
Widget _highlightSearchTerm(String text, String searchTerm) {
  if (searchTerm.isEmpty) {
    return Text(text);
  }

  List<TextSpan> spans = [];
  int start = 0;
  int indexOfHighlight;
  do {
    indexOfHighlight = text.toLowerCase().indexOf(searchTerm.toLowerCase(), start);
    if (indexOfHighlight < 0) {
      // Přidání zbývajícího textu, který neobsahuje vyhledávaný výraz
      spans.add(TextSpan(text: text.substring(start)));
      break;
    }
    if (indexOfHighlight > start) {
      // Přidání textu před vyhledávaným výrazem
      spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
    }
    // Přidání zvýrazněného textu s vyhledávaným výrazem
    spans.add(TextSpan(
      text: text.substring(indexOfHighlight, indexOfHighlight + searchTerm.length),
      style: TextStyle(color: Color(0xFFE50E2B)), // Změna barvy textu na červenou color: Color(0xFFE50E2B)
    ));
    start = indexOfHighlight + searchTerm.length;
  } while (start < text.length);

  return RichText(text: TextSpan(style: TextStyle(color: Colors.black), children: spans));
}
}

