import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'settings_page.dart';
import 'search_page.dart'; // Předpokládáme, že máte soubor search_page.dart
import 'add_note.dart';
import 'diary_controller.dart';
import 'diary_entries_loader.dart';
import 'flow.dart';
import 'get_code.dart';

class CalendarPage extends StatefulWidget {
  final int _selectedIndex = 0;

  const CalendarPage({Key? key}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<FlowData?> _allRecords = [];

  late Future<FlowData?> _recordFuture;

  String record1 = '';
  String record2 = '';
  String record3 = '';
  String score = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchAllRecords();
    _recordFuture = _loadDay(_focusedDay);
  }

  // Funkce pro načtení záznamů z deníku
  void _fetchAllRecords() async {
    List<FlowData> records = await diaryController.readEntries();
    setState(() {
      _allRecords = records;
    });
  }

  Future<FlowData?> _loadDay(DateTime date) async {
    var dayRecords = _allRecords
        .where(
          (record) => isSameDay(record?.day, date),
        )
        .toList();

    var dayRecord = dayRecords.isNotEmpty ? dayRecords.first : null;

    return dayRecord;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // Kdyby byla domovská stránka na indexu 0
        // Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        // Přechod na stránku pro vyhledávání
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SearchPage()));
        break;
      case 2:
        // PsychoUserPage
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PsychoUserPage()));
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 16,
            ),
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.95,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  locale: 'cs_CZ',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  shouldFillViewport: true,
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, events) {
                      return Container(
                        margin: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFE50E2B), // Zde změňte barvu na požadovanou
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      );
                    },
                    markerBuilder: (context, date, events) {
                      var dayRecords = _allRecords
                          .where(
                            (record) => isSameDay(record?.day, date),
                          )
                          .toList();

                      var dayRecord =
                          dayRecords.isNotEmpty ? dayRecords.first : null;

                      // Kontrola, zda je den vybraný a zároveň ve stejném měsíci jako _focusedDay
                      bool isFocused = isSameDay(_selectedDay, date);

                      if (dayRecord != null && dayRecord.score != null) {
                        Color scoreColor;
                        Color textColor = Colors.white;

                        if (isSameDay(_selectedDay, date)) {
                          scoreColor = Color(0xFFE50E2B);
                        } else if (isSameDay(date, DateTime.now())) {
                          scoreColor = Color(0xFFE2AFB6);
                          textColor = Colors.black;
                        } else if (_focusedDay.month != date.month) {
                          scoreColor = Color(0xFFBBBBBB);
                          textColor = Color(0xFF6E6E6E);
                        } else {
                          scoreColor = Color(0xFFEAEAEA);
                          textColor = Colors.black;
                        }

                        FontWeight fontWeight =
                            isFocused ? FontWeight.bold : FontWeight.normal;

                        // Získání šířky obrazovky
                        double screenWidth =
                            (MediaQuery.of(context).size.width * 0.95);
                        // Vypočítání šířky jednoho dne
                        double dayWidth = screenWidth / 7 - 12;

                        // Zobrazit skóre pod dnem
                        return Positioned(
                          bottom: 6.0,
                          child: Container(
                            width: dayWidth,
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: scoreColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                            ),
                            child: Text(
                              '${dayRecord.score}/10',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: fontWeight,
                                color: textColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    defaultDecoration: BoxDecoration(
                        shape: BoxShape
                            .rectangle, // You can use different shapes like BoxShape.rectangle
                        color: const Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(10.0)),
                    defaultTextStyle: const TextStyle(
                      fontSize: 15, // Set the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set the text color as needed
                    ),
                    weekendDecoration: BoxDecoration(
                        shape: BoxShape
                            .rectangle, // You can use different shapes like BoxShape.rectangle
                        color: const Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(10.0)),
                    weekendTextStyle: const TextStyle(
                      fontSize: 15, // Set the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set the text color as needed
                    ),
                    outsideDecoration: BoxDecoration(
                      shape: BoxShape
                        .rectangle, // You can use different shapes like BoxShape.rectangle
                      color: const Color(0xFFBBBBBB),
                      borderRadius: BorderRadius.circular(
                        10.0) // Background color of the day cell
                    ),
                    outsideTextStyle: const TextStyle(
                      fontSize: 15, // Set the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E6E6E), // Set the text color as needed
                    ),
                    selectedDecoration: BoxDecoration(
                        shape: BoxShape
                            .rectangle, // You can use different shapes like BoxShape.rectangle
                        color: const Color(0xFFE50E2B),
                        borderRadius: BorderRadius.circular(10.0)),
                    selectedTextStyle: const TextStyle(
                      fontSize: 15, // Set the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set the text color as needed
                    ),
                    todayDecoration: BoxDecoration(
                        shape: BoxShape
                            .rectangle, // You can use different shapes like BoxShape.rectangle
                        color: const Color(0xFFE2AFB6),
                        borderRadius: BorderRadius.circular(10.0)),
                    todayTextStyle: const TextStyle(
                      fontSize: 15, // Set the font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set the text color as needed
                    ),
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (selectedDay.isAfter(DateTime.now())) {
                      // Pokud je vybraný den v budoucnosti, nedělejte nic (nebo zobrazte chybovou zprávu)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Nelze vybrat budoucí datum!",
                            style: TextStyle(
                              color: Colors.black, // Text color
                            ),
                          ),
                          duration: Duration(seconds: 3), // Duration of the SnackBar display
                          backgroundColor: Color(0xFFEAEAEA),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _focusedDay = focusedDay;
                      _selectedDay = selectedDay;
                      _recordFuture = _loadDay(selectedDay);
                    });
                  },

                  //onPageChanged: (focusedDay) {
                  //  _focusedDay = focusedDay;
                  //},
                  
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, size: 40),
                    rightChevronIcon: Icon(Icons.chevron_right, size: 40),
                  ),
                  // Další přizpůsobení vzhledu, pokud je to potřeba
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
              child: FutureBuilder<FlowData?>(
                future: _recordFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Došlo k chybě při načítání dat');
                  } else {
                    FlowData? record = snapshot.data;
                    return Column(
                      children: [
                        if ((record?.record1 ?? '').isNotEmpty)
                          Container(
                            width: 380,
                            constraints: const BoxConstraints(minHeight: 50.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFBCBCBC),
                                  width: 1.8), // Optional: Add border
                              borderRadius: BorderRadius.circular(
                                  10.0), // Optional: Add border radius
                            ),
                            padding: const EdgeInsets.all(
                                8.0), // Optional: Add padding
                            margin: const EdgeInsets.all(
                                4.0), // Optional: Add margin
                            child: Text(
                              record?.record1 ?? '',
                              style: const TextStyle(
                                  color: Color(0xFF5b5b5b)), // Set text color
                            ),
                          ),
                        if ((record?.record2 ?? '').isNotEmpty)
                          Container(
                            width: 380,
                            constraints: const BoxConstraints(minHeight: 50.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFBCBCBC),
                                  width: 1.8), // Optional: Add border
                              borderRadius: BorderRadius.circular(
                                  10.0), // Optional: Add border radius
                            ),
                            padding: const EdgeInsets.all(
                                8.0), // Optional: Add padding
                            margin: const EdgeInsets.all(
                                4.0), // Optional: Add margin
                            child: Text(
                              record?.record2 ?? '',
                              style: const TextStyle(
                                  color: Color(0xFF5b5b5b)), // Set text color
                            ),
                          ),
                        if ((record?.record3 ?? '').isNotEmpty)
                          Container(
                            width: 380,
                            constraints: const BoxConstraints(minHeight: 50.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFBCBCBC),
                                  width: 1.8), // Optional: Add border
                              borderRadius: BorderRadius.circular(
                                  10.0), // Optional: Add border radius
                            ),
                            padding: const EdgeInsets.all(
                                8.0), // Optional: Add padding
                            margin: const EdgeInsets.all(
                                4.0), // Optional: Add margin
                            child: Text(
                              record?.record3 ?? '',
                              style: const TextStyle(
                                  color: Color(0xFF5b5b5b)), // Set text color
                            ),
                          ),
                      ],
                    );
                  }
                },
              ),
            ))
          ]),
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
                  color: widget._selectedIndex == 0 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.search,
                  color: widget._selectedIndex == 1 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(
                width: 48), // The empty space in middle of the BottomAppBar
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.message,
                  color: widget._selectedIndex == 2 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.person_outline,
                  color: widget._selectedIndex == 3 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(size: 35, Icons.add),
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
