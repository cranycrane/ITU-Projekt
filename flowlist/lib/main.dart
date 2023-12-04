import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'auth_controller.dart';
import 'auth_page.dart';
import 'calendar_screen.dart';
import 'diary_controller.dart';
import 'deviceUtils.dart';
import 'storage_service.dart';

void main() async {
  initializeDateFormatting().then((_) => runApp(MyApp()));
  WidgetsFlutterBinding.ensureInitialized();

  // Získání ID zařízení
  String? deviceId = await DeviceUtils.getDeviceId();

  // Uložení ID zařízení
  await StorageService().saveDeviceId(deviceId);

  print('Device ID: $deviceId');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowList',
      home: CalendarPage(),
    );
  }
}
