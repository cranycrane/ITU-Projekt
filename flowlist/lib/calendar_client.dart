import 'package:flowlist/messages_page.dart';
import 'package:flowlist/psycho_overview.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'diary_controller.dart';
//import 'diary_entries_loader.dart';
import 'flow.dart';
import 'user_profile.dart';
//import 'user_controller.dart';
//import 'dart:io';
import 'psycho_note_read.dart';
import 'statistics_page.dart';

class CalendarClientPage extends StatefulWidget {
  final UserProfile client;

  const CalendarClientPage({Key? key, required this.client}) : super(key: key);

  final int _selectedIndex = 1;

  @override
  CalendarClientPageState createState() => CalendarClientPageState();
}

class CalendarClientPageState extends State<CalendarClientPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<FlowData?> _allRecords = [];

  late FlowData? _record;

  String record1 = '';
  String record2 = '';
  String record3 = '';
  String score = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchAllRecords();
    _record = _loadDay(_focusedDay);
  }

  // Funkce pro načtení záznamů z deníku
  void _fetchAllRecords() async {
    List<FlowData> records =
        await diaryController.readEntries(widget.client.userId.toString());
    setState(() {
      _allRecords = records;
      _record = _loadDay(_focusedDay);
    });
  }

  FlowData? _loadDay(DateTime date) {
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
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PsychoOverviewPage()));
        break;
      case 2:
        // PsychoUserPage
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CalendarClientPage(client: widget.client)));
        // Tady byste mohli implementovat přechod na stránku oznámení
        break;
      case 3:
        // Navigace na SettingsPage, pokud uživatel není již na této stránce

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MessagesPage(
                  toUserId: widget.client.userId.toString(),
                )));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StatisticsPage(
                  userId: widget.client.userId.toString(),
                )));
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
                    todayBuilder: (context, day, focusedDay) {
                      return Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFE2AFB6), // Zde změňte barvu na požadovanou
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      );
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      return Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFBBBBBB), // Zde změňte barvu na požadovanou
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                                color: Color(0xFF6E6E6E),
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFEAEAEA), // Zde změňte barvu na požadovanou
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, date, events) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFE50E2B), // Zde změňte barvu na požadovanou
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(
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
                      //bool isFocused = isSameDay(_selectedDay, date);

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

                        FontWeight fontWeight = FontWeight.bold;

                        // Získání šířky obrazovky
                        double screenWidth =
                            (MediaQuery.of(context).size.width * 0.95);
                        // Vypočítání šířky jednoho dne
                        double dayWidth = screenWidth / 7 - 12;

                        // Zobrazit skóre pod dnem
                        return Positioned(
                          bottom: 2.0,
                          child: Container(
                            width: dayWidth,
                            padding: const EdgeInsets.all(5.0),
                            decoration: const BoxDecoration(
                              //color: scoreColor,
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
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (selectedDay.isAfter(DateTime.now())) {
                      // Pokud je vybraný den v budoucnosti, nedělejte nic (nebo zobrazte chybovou zprávu)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Nelze vybrat budoucí datum!",
                            style: TextStyle(
                              color: Colors.white, // Text color
                            ),
                          ),
                          duration: Duration(
                              seconds: 3), // Duration of the SnackBar display
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _focusedDay = focusedDay;
                      _selectedDay = selectedDay;
                      _record = _loadDay(selectedDay);
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
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PsychoEntryPage(
                              selectedDay: _selectedDay, client: widget.client),
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        if ((_record?.record1 ?? '').isNotEmpty)
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
                              _record?.record1 ?? '',
                              maxLines: 2,
                              style: const TextStyle(
                                  color: Color(0xFF5b5b5b)), // Set text color
                            ),
                          ),
                        if ((_record?.record2 ?? '').isNotEmpty)
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
                              _record?.record2 ?? '',
                              maxLines: 2,
                              style: const TextStyle(
                                  color: Color(0xFF5b5b5b)), // Set text color
                            ),
                          ),
                        if ((_record?.record3 ?? '').isNotEmpty)
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
                              _record?.record3 ?? '',
                              maxLines: 2,
                              style: const TextStyle(
                                  color: Color(0xFF5b5b5b)), // Set text color
                            ),
                          ),
                      ],
                    ))))
          ]),
      bottomNavigationBar: BottomAppBar(
          height: 70,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                      size: 35,
                      Icons.home,
                      color: widget._selectedIndex == 0
                          ? Colors.red
                          : Colors.grey),
                  onPressed: () => _onItemTapped(1),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Přidání akce, která se provede po kliknutí
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => CalendarClientPage(
                                  client: widget.client,
                                )), // Změňte na cílovou stránku
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          width: 2.0,
                          color: widget._selectedIndex == 1
                              ? Color(0xFFE50E2B)
                              : Colors.grey,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Colors.grey[200],
                            child: widget.client.imageFile == null
                                ? const Icon(Icons.person, size: 60)
                                : ClipOval(
                                    child: Image.file(
                                    widget.client.imageFile!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )),
                          ),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  "${widget.client.firstName} ${widget.client.lastName}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.only(right: 5),
                  icon: Icon(
                      size: 35,
                      Icons.query_stats,
                      color: widget._selectedIndex == 2
                          ? Colors.red
                          : Colors.grey),
                  onPressed: () => _onItemTapped(4),
                ),
                IconButton(
                  padding: const EdgeInsets.only(right: 5),
                  icon: Icon(
                      size: 35,
                      Icons.message,
                      color: widget._selectedIndex == 2
                          ? Colors.red
                          : Colors.grey),
                  onPressed: () => _onItemTapped(3),
                ),
              ],
            ),
          )),
    );
  }
}

class UserDetailsWidget extends StatelessWidget {
  final String userName;
  final String userPhotoUrl;

  UserDetailsWidget({required this.userName, required this.userPhotoUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircleAvatar(
          backgroundImage: NetworkImage(userPhotoUrl),
          // případně můžete použít AssetImage pro lokální obrázky
        ),
        const SizedBox(width: 8),
        Text(userName, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
