import 'package:flutter/material.dart';
import 'flow.dart';
import 'diary_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_colors.dart';

class StatisticsPage extends StatefulWidget {
  final String? userId;

  const StatisticsPage({Key? key, this.userId}) : super(key: key);

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {
  List<FlowData> _allRecords = [];
  List<FlowData> _monthRecords = [];
  List<FlSpot> _lineChartSpots = []; // Initialized as an empty list
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
      List<FlowData> allRecords =
          await diaryController.readEntries(widget.userId);
      List<FlowData> filteredRecords = allRecords.where((record) {
        return record.day.year == _selectedMonth.year &&
            record.day.month == _selectedMonth.month;
      }).toList();

      // Sort the records from oldest to newest
      filteredRecords.sort((a, b) => a.day.compareTo(b.day));

      _lineChartSpots = _generateChartData(filteredRecords);

      setState(() {
        _allRecords = allRecords;
        _monthRecords = filteredRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _getMonthRecords() async {
    try {
      List<FlowData> filteredRecords = _allRecords.where((record) {
        return record.day.year == _selectedMonth.year &&
            record.day.month == _selectedMonth.month;
      }).toList();

      // Sort the records from oldest to newest
      filteredRecords.sort((a, b) => a.day.compareTo(b.day));

      _lineChartSpots = _generateChartData(filteredRecords);

      setState(() {
        _monthRecords = filteredRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _goToNextMonth() {
    DateTime now = DateTime.now();
    DateTime nextMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);

    // Check if the next month is in the future compared to the current month and year
    if (nextMonth.year > now.year ||
        (nextMonth.year == now.year && nextMonth.month > now.month)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nelze zobrazit budoucí měsíc!",
            style: TextStyle(
              color: Colors.black, // Text color
            ),
          ),
          duration: Duration(seconds: 3), // Duration of the SnackBar display
          backgroundColor:  AppColors.lightGrey,
        ),
      );
      return; // Do nothing if trying to go into the future
    }
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
      _getMonthRecords(); // Re-fetch or update your data for the new month
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      _getMonthRecords(); // Re-fetch or update your data for the new month
    });
  }

  int _numberOfDaysInMonth(DateTime date) {
    DateTime firstDayNextMonth = (date.month < 12)
        ? DateTime(date.year, date.month + 1, 1)
        : DateTime(date.year + 1, 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  double _calculateMeanScore(List<FlowData?> records) {
    if (records.isEmpty) {
      return 0.0;
    }
    double sum =
        records.fold(0, (total, record) => total + (record?.score ?? 0));
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
    return date.day
        .toDouble(); // Simple example, you may need more complex logic
  }

  @override
  Widget build(BuildContext context) {
    String meanScoreText;
    if (_monthRecords.isEmpty) {
      meanScoreText = '-';
    } else {
      double meanScore = _calculateMeanScore(_monthRecords);
      meanScoreText = meanScore.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistiky vašich hodnocení',
          style: TextStyle(fontSize: 22, color: AppColors.darkGrey),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.darkGrey,
          iconSize: 40, // Zvětšení velikosti ikony
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 30),
                        onPressed: _goToPreviousMonth,
                      ),
                      Text(
                        '${DateFormat('MMMM', 'cs_CZ').format(_selectedMonth)} ${DateFormat('y', 'cs_CZ').format(_selectedMonth)}',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 30),
                        onPressed: _goToNextMonth,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 30.0, top: 10.0, bottom: 15.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 25, color: Colors.black), // Default style
                        children: <TextSpan>[
                          const TextSpan(text: 'Průměrné hodnocení dne: '),
                          TextSpan(
                            text: meanScoreText,
                            style: const TextStyle(
                                fontSize: 28,
                                color: AppColors.red,
                                fontWeight: FontWeight
                                    .bold), // Specific style for the score
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 5),
                    child: LineChart(
                      LineChartData(
                        minX: 1,
                        maxX: _numberOfDaysInMonth(_selectedMonth).toDouble(),
                        minY: 0,
                        maxY: 10,
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 4.0,
                                  reservedSize: 35.0)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1.0,
                                  reservedSize: 30.0)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _lineChartSpots,
                            isCurved: false,
                            barWidth: 3,
                            color: AppColors.red,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 200),
              ],
            ),
    );
  }
}
