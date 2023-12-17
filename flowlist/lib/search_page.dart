import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'settings_page.dart';
import 'add_note.dart';
import 'flow.dart';
import 'diary_controller.dart';
import 'package:intl/intl.dart';
import 'get_code.dart';
import 'app_colors.dart';

// Definice třídy stavového widgetu pro vyhledávací stránku
class SearchPage extends StatefulWidget {
  final int _selectedIndex = 1;

  const SearchPage({Key? key}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

// Třída stavu pro vyhledávací stránku
class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FlowData> _allRecords = []; // List pro uložení všech záznamů
  List<FlowData> _filteredRecords =
      []; // Filtr pro zobrazení výsledků vyhledávání

  @override
  void initState() {
    super.initState();
    _fetchAllRecords(); // Načtení všech záznamů při inicializaci
  }

  void _fetchAllRecords() async {
    // Asynchronní načtení všech záznamů
    List<FlowData> records = await diaryController.readEntries();
    setState(() {
      _allRecords = records; // Uložení záznamů do stavu
    });
  }

  void _performSearch(String query) async {
    List<FlowData> filteredRecords = await _filterEntries(query);
    setState(() {
      _filteredRecords = filteredRecords; // Aktualizace stavu s filtrovanými záznamy
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

 // Implementace navigace na základě vybrané položky v navigační liště
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;
      case 1:

        break;
      case 2:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const PsychoUserPage()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Zde je vybudováné celé uživatelské rozhraní stránky
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
                prefixIcon: const Icon(Icons.search, color: AppColors.red),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.red),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _performSearch(value);
              },
              onSubmitted: (value) {},
            ),
          ),
          _buildSearchResults(),
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
                      :  AppColors.middleGrey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.search,
                  color: widget._selectedIndex == 1
                      ? AppColors.red
                      :  AppColors.middleGrey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.message,
                  color: widget._selectedIndex == 2
                      ? AppColors.red
                      :  AppColors.middleGrey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.person_outline,
                  color: widget._selectedIndex == 3
                      ? AppColors.red
                      :  AppColors.middleGrey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        child: const Icon(size: 35, Icons.add),
        onPressed: () {
          // Získání aktuálního data
          DateTime currentDate = DateTime.now();

          // Navigace na NewEntryPage s aktuálním datem
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => NewEntryPage(selectedDay: currentDate),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

// Vytvoření widgetu pro zobrazení výsledků vyhledávání
  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return const Center(child: Text("Zadejte hledaný výraz."));
    }
    if (_filteredRecords.isEmpty) {
      return const Center(child: Text("Žádné výsledky vyhledávání"));
    }

    String searchQuery = _searchController.text.toLowerCase();

    List<Widget> searchResultsWidgets = [];
    for (var entry in _filteredRecords) {
      // Kontrola, zda některý záznam obsahuje vyhledávané slovo
      bool containsInRecord1 =
          entry.record1.toLowerCase().contains(searchQuery);
      bool containsInRecord2 =
          entry.record2.toLowerCase().contains(searchQuery);
      bool containsInRecord3 =
          entry.record3.toLowerCase().contains(searchQuery);

      if (containsInRecord1 || containsInRecord2 || containsInRecord3) {
        searchResultsWidgets.add(
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => NewEntryPage(selectedDay: entry.day),
                ));
              },
              child: ListTile(
                title: Text(
                  DateFormat('dd.MM.yyyy').format(entry.day),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (containsInRecord1)
                      _highlightSearchTerm(entry.record1, searchQuery),
                    if (containsInRecord2)
                      _highlightSearchTerm(entry.record2, searchQuery),
                    if (containsInRecord3)
                      _highlightSearchTerm(entry.record3, searchQuery),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      child: Column(children: searchResultsWidgets),
    );
  }

// Funkce pro zvýraznění vyhledávaného termínu ve výsledcích
  Widget _highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty) {
      return Text(text);
    }

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;
    do {
      indexOfHighlight =
          text.toLowerCase().indexOf(searchTerm.toLowerCase(), start);
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
        text: text.substring(
            indexOfHighlight, indexOfHighlight + searchTerm.length),
        style: const TextStyle(
            color: AppColors.red),
      ));
      start = indexOfHighlight + searchTerm.length;
    } while (start < text.length);

    return RichText(
        text: TextSpan(
            style: const TextStyle(color: Colors.black), children: spans));
  }
}
