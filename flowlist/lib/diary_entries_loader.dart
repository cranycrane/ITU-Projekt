import 'package:intl/intl.dart';

import 'diary_controller.dart';
import 'flow.dart';

class DiaryEntriesLoader {
  final DiaryController diaryController;

  DiaryEntriesLoader(this.diaryController);

  Future<FlowData> loadDiaryEntries(DateTime selectedDay,
      [String? userId]) async {
    try {
      List<Map<String, dynamic>> entries;
      if (userId != null) {
        entries = await diaryController.readEntry(selectedDay, userId);
      } else {
        entries = await diaryController.readEntry(selectedDay);
      }

      if (entries.isNotEmpty) {
        return FlowData(
            record1: entries[0]['record1'] ?? '',
            record2: entries[0]['record2'] ?? '',
            record3: entries[0]['record3'] ?? '',
            day: DateFormat('yyyy-MM-dd').parse(entries[0]['date']),
            score: entries[0]['score'] ?? '');
      } else {
        return FlowData(day: selectedDay);
      }
    } catch (error) {
      throw Exception("error loading entries $error");
    }
  }
}
