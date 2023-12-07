import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'calendar_screen.dart';
import 'diary_controller.dart';
import 'deviceUtils.dart';
import 'storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(); // Inicializace formátování data

  // Získání ID zařízení
  String? deviceId = await DeviceUtils.getDeviceId();
  // Ziskej ID uzivatele
  String userId = await diaryController.getUserId(deviceId);
  // Uložení ID zařízení
  await StorageService().saveUserId(userId);
  print('Device ID: $deviceId UserId: $userId');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FlowList',
      home: CalendarPage(),
    );
  }
}
