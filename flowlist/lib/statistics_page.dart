import 'package:flowlist/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'user_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'user_profile.dart';
import 'settings_page.dart';
import 'flow.dart';
import 'diary_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<FlowData?> _allRecords = [];
  List<FlSpot> _lineChartSpots = [];  // Initialized as an empty list
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();
  

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('cs_CZ', null);
    _fetchAllRecords();
  }

  void _fetchAllRecords() async {
    try {
      List<FlowData> allRecords = await diaryController.readEntries();
      List<FlowData> filteredRecords = allRecords.where((record) {
        return record.day.year == _selectedMonth.year &&
              record.day.month == _selectedMonth.month;
      }).toList();

      // Sort the records from oldest to newest
      filteredRecords.sort((a, b) => a.day.compareTo(b.day));

      _lineChartSpots = _generateChartData(filteredRecords);

      setState(() {
        _allRecords = filteredRecords;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading records: $e');
      setState(() => _isLoading = false);
    }
  }

  void _goToNextMonth() {
    DateTime now = DateTime.now();
    DateTime nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);

    // Check if the next month is in the future compared to the current month and year
    if (nextMonth.year > now.year || (nextMonth.year == now.year && nextMonth.month > now.month)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Nelze zobrazit budoucí měsíc!",
            style: TextStyle(
              color: Colors.black, // Text color
            ),
          ),
          duration: Duration(seconds: 3), // Duration of the SnackBar display
          backgroundColor: Color(0xFFEAEAEA),
        ),
      );
      return; // Do nothing if trying to go into the future
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
      _fetchAllRecords();// Re-fetch or update your data for the new month
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      _fetchAllRecords();// Re-fetch or update your data for the new month
    });
  }

  int numberOfDaysInMonth(DateTime date) {
    DateTime firstDayNextMonth = (date.month < 12)
        ? DateTime(date.year, date.month + 1, 1)
        : DateTime(date.year + 1, 1, 1);
    return firstDayNextMonth.subtract(Duration(days: 1)).day;
  }

  double _calculateMeanScore(List<FlowData?> records) {
    if (records.isEmpty) {
      return 0.0;
    }
    double sum = records.fold(0, (total, record) => total + (record?.score ?? 0));
    return sum / records.length;
  }

  List<FlSpot> _generateChartData(List<FlowData> records) {
    List<FlSpot> spots = [];
    for (var record in records) {
      double xValue = _dateToAxisValue(record.day); 
      double yValue = record.score?.toDouble() ?? 0; // Default to 0 if score is null
      spots.add(FlSpot(xValue, yValue));
    }
    return spots;
  }

  double _dateToAxisValue(DateTime? date) {
    if (date == null) return 0;
    return date.day.toDouble(); // Simple example, you may need more complex logic
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = numberOfDaysInMonth(_selectedMonth);
    double meanScore = _calculateMeanScore(_allRecords);
    String meanScoreText;
    if (_allRecords.isEmpty) {
      meanScoreText = '-';
    } else {
      double meanScore = _calculateMeanScore(_allRecords);
      meanScoreText = meanScore.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistiky vašich hodnocení',
          style: TextStyle(fontSize: 26, color: Color(0xFF61646B)),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 85,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xFF61646B),
          iconSize: 40, // Zvětšení velikosti ikony
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, size: 30),
                      onPressed: _goToPreviousMonth,
                    ),
                    Text(
                      DateFormat('MMMM', 'cs_CZ').format(_selectedMonth) + ' ' + DateFormat('y', 'cs_CZ').format(_selectedMonth),
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, size: 30),
                      onPressed: _goToNextMonth,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:30.0, top:10.0, bottom:15.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 25, color: Colors.black), // Default style
                      children: <TextSpan>[
                        const TextSpan(text: 'Průměrné hodnocení dne: '),
                        TextSpan(
                          text: meanScoreText,
                          style: const TextStyle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold), // Specific style for the score
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:0.0),
                child: Text(
                  'hodnocení všech dnů tento měsíc:',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 5),
                  child: LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: daysInMonth.toDouble(),
                      minY: 0,
                      maxY: 10,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _lineChartSpots,
                          isCurved: false,
                          barWidth: 3,
                          color: Colors.red,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 200),
            ],
        ),
    );
  }
}