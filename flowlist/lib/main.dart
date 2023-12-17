/// Aplikace Flow-List
/// FIT VUT, ITU - Tvorba uzivatelskych rozhrani
/// Autor: Jakub Jerabek (xjerab28), Vojtech Teichmann (xteich02), Doubravka Simunkova (xsimun05)
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'calendar_screen.dart';
import 'diary_controller.dart';
import 'device_utils.dart';
import 'storage_service.dart';
import 'welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(); // Inicializace formátování data

  // Získání ID zařízení
  String? deviceId = await DeviceUtils.getDeviceId();
  // Ziskej ID uzivatele
  Map<String, dynamic> userInfo = await diaryController.getUserId(deviceId);
  bool firstLogin = userInfo['firstLogin'];
  // Uložení ID zařízení
  await StorageService().saveUserId(userInfo['userId'].toString());

  runApp(MyApp(
    firstLogin: firstLogin,
  ));
}

class MyApp extends StatelessWidget {
  final bool firstLogin;
  const MyApp({Key? key, required this.firstLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (firstLogin) {
      return MaterialApp(
        title: 'FlowList',
        home: WelcomePage(onlyLooking: false),
      );
    } else {
      return const MaterialApp(
        title: 'FlowList',
        home: CalendarPage(),
      );
    }
  }
}
