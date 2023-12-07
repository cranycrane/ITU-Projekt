import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'settings_page.dart';
import 'search_page.dart'; // Předpokládáme, že máte soubor search_page.dart
import 'add_note.dart';
import 'diary_controller.dart';
import 'diary_entries_loader.dart';
import 'flow.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  late Future<FlowData?> _recordFuture;

  String record1 = '';
  String record2 = '';
  String record3 = '';
  String score = '';

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _recordFuture = _loadData(_selectedDay);
  }

  // Funkce pro načtení záznamů z deníku
  Future<FlowData?> _loadData(DateTime selectedDay) async {
    DiaryEntriesLoader loader = DiaryEntriesLoader(diaryController);
    return await loader.loadDiaryEntries(selectedDay);
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }

    switch (index) {
      case 0:
        // Kdyby byla domovská stránka na indexu 0
        // Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        // Přechod na stránku pro vyhledávání
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 2:
        // Tady byste mohli implementovat přechod na stránku oznámení
        break;
      case 3:
        // Navigace na SettingsPage, pokud uživatel není již na této stránce

        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView( // Přidáváme SingleChildScrollView
              child: Container(
                padding: const EdgeInsets.only(top: 30.0), // Adjust the top padding as needed
                child: SizedBox(
                  height: 450,
                  width: 400,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    locale: 'cs_CZ',
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    shouldFillViewport: true,
                    calendarStyle: CalendarStyle(
                      defaultDecoration: BoxDecoration(
                        shape: BoxShape.rectangle, // You can use different shapes like BoxShape.rectangle
                        color: Color(0xFFEAEAEA), 
                        borderRadius: BorderRadius.circular(10.0)
                      ),
                      defaultTextStyle: TextStyle(
                        fontSize: 15, // Set the font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Set the text color as needed
                      ),
                      weekendDecoration: BoxDecoration(
                        shape: BoxShape.rectangle, // You can use different shapes like BoxShape.rectangle
                        color: Color(0xFFEAEAEA), 
                        borderRadius: BorderRadius.circular(10.0) 
                      ),
                      weekendTextStyle: TextStyle(
                        fontSize: 15, // Set the font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Set the text color as needed
                      ),
                      outsideDecoration: BoxDecoration(
                        shape: BoxShape.rectangle, // You can use different shapes like BoxShape.rectangle
                        color: Color(0xFFBBBBBB), 
                        borderRadius: BorderRadius.circular(10.0)      // Background color of the day cell
                      ),
                      outsideTextStyle: TextStyle(
                        fontSize: 15, // Set the font size as needed
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E6E6E), // Set the text color as needed
                      ),
                      selectedDecoration: BoxDecoration(
                        shape: BoxShape.rectangle, // You can use different shapes like BoxShape.rectangle
                        color: Color(0xFFE50E2B), 
                        borderRadius: BorderRadius.circular(10.0)
                      ),
                      selectedTextStyle: TextStyle(
                        fontSize: 15, // Set the font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Set the text color as needed
                      ),
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.rectangle, // You can use different shapes like BoxShape.rectangle
                        color: Color(0xFFE2AFB6), 
                        borderRadius: BorderRadius.circular(10.0)
                      ),
                      todayTextStyle: TextStyle(
                        fontSize: 15, // Set the font size as needed
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Set the text color as needed
                      ),

                      // You can add more customization options as needed
                    ),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                        _selectedDay = selectedDay;
                        _recordFuture = _loadData(selectedDay);
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, size: 40),
                      rightChevronIcon: Icon(Icons.chevron_right, size: 40),
                    ),
                    // Další přizpůsobení vzhledu, pokud je to potřeba
                  ),
                )
              )
            ),
          ),
          const SizedBox(
              height: 20), // volitelná mezera mezi kalendářem a textovým polem
          FutureBuilder<FlowData?>(
            future: _recordFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Došlo k chybě při načítání dat');
              } else {
                FlowData? record = snapshot.data;
                return Column(
                  children: [
                    Text(record?.record1 ?? ''),
                    Text(record?.record2 ?? ''),
                    Text(record?.record3 ?? ''),
                  ],
                );
              }
            },
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
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.search,
                  color: _selectedIndex == 1 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(
                width: 48), // The empty space in middle of the BottomAppBar
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
          // Akce pro FloatingActionButton
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewEntryPage(selectedDay: _selectedDay),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
