/// Aplikace Flow-List
/// FIT VUT, ITU - Tvorba uzivatelskych rozhrani
/// Autor: Jakub Jerabek (xjerab28)
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'settings_page.dart';
import 'search_page.dart';
import 'add_note.dart';
import 'diary_controller.dart';

import 'flow.dart';
import 'get_code.dart';
import 'app_colors.dart';

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

  void _fetchAllRecords() async {
    List<FlowData> records = await diaryController.readEntries();
    setState(() {
      _allRecords = records;
      _recordFuture = _loadDay(_focusedDay);
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
        break;
      case 1:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SearchPage()));
        break;
      case 2:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PsychoUserPage()));

        break;
      case 3:
        Navigator.of(context).pushReplacement(
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
                height: MediaQuery.of(context).size.height * 0.60,
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
                        margin: const EdgeInsets.symmetric(
                            horizontal: 3.0, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.lightRed,
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
                        margin: const EdgeInsets.symmetric(
                            horizontal: 3.0, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.middleGrey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 3.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
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
                            horizontal: 3.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: AppColors.red,
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

                      if (dayRecord != null && dayRecord.score != null) {
                        Color textColor = Colors.white;

                        if (isSameDay(_selectedDay, date)) {
                          textColor = Colors.white;
                        } else if (isSameDay(date, DateTime.now())) {
                          textColor = Colors.black;
                        } else if (_focusedDay.month != date.month) {
                          textColor = AppColors.darkGrey;
                        } else {
                          textColor = Colors.black;
                        }

                        FontWeight fontWeight = FontWeight.bold;

                        double screenWidth =
                            (MediaQuery.of(context).size.width * 0.95);

                        double dayWidth = screenWidth / 7 - 12;

                        return Positioned(
                          bottom: 4.0,
                          child: Container(
                            width: dayWidth,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: const BoxDecoration(
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Nelze vybrat budoucí datum!",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          duration: Duration(seconds: 3),
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
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Expanded(
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              NewEntryPage(selectedDay: _selectedDay),
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      child: FutureBuilder<FlowData?>(
                        future: _recordFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                    constraints:
                                        const BoxConstraints(minHeight: 50.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.middleGrey,
                                          width: 1.8),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.all(4.0),
                                    child: Text(
                                      record?.record1 ?? '',
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: AppColors.darkGrey),
                                    ),
                                  ),
                                if ((record?.record2 ?? '').isNotEmpty)
                                  Container(
                                    width: 380,
                                    constraints:
                                        const BoxConstraints(minHeight: 50.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.middleGrey,
                                          width: 1.8),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.all(4.0),
                                    child: Text(
                                      record?.record2 ?? '',
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: AppColors.darkGrey),
                                    ),
                                  ),
                                if ((record?.record3 ?? '').isNotEmpty)
                                  Container(
                                    width: 380,
                                    constraints:
                                        const BoxConstraints(minHeight: 50.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.middleGrey,
                                          width: 1.8),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.all(4.0),
                                    child: Text(
                                      record?.record3 ?? '',
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: AppColors.darkGrey),
                                    ),
                                  ),
                              ],
                            );
                          }
                        },
                      ),
                    )))
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
            const SizedBox(width: 48),
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
          Navigator.of(context).pushReplacement(
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
