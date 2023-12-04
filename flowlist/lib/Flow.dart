import 'package:intl/intl.dart';

class FlowData {
  String record1;
  String record2;
  String record3;
  DateTime day;
  int score;

  FlowData({
    required this.record1,
    required this.record2,
    required this.record3,
    required this.day,
    required this.score,
  });

  static FlowData fromFields({
    required String record1,
    required String record2,
    required String record3,
    required DateTime day,
    required int score,
  }) {
    return FlowData(
      record1: record1,
      record2: record2,
      record3: record3,
      day: day,
      score: score,
    );
  }

  Map<String, dynamic> toJson() => {
        'record1': record1,
        'record2': record2,
        'record3': record3,
        'day': DateFormat('yyyy-MM-dd').format(day),
        'score': score,
      };
}
