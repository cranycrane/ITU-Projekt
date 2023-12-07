import 'package:intl/intl.dart';

class FlowData {
  String record1;
  String record2;
  String record3;
  DateTime day;
  int? score;

  FlowData({
    this.record1 = '',
    this.record2 = '',
    this.record3 = '',
    required this.day,
    this.score = -1,
  });

  factory FlowData.fromJson(Map<String, dynamic> json) {
    return FlowData(
      record1: json['record1'],
      record2: json['record2'],
      record3: json['record3'],
      score: json['score'],
      day: DateTime.parse(json['date']),
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
