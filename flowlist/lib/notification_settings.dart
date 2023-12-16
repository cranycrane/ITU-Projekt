import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  String selectedOption =
      'Jaký byl tvůj dnešní den? Vzpomeneš si na 3 věci, které ti dnes vytvořily úsměv na tváři? Otevři svůj Flow-lístek!';
  bool isCustomOption = false;

  TimeOfDay selectedTime = TimeOfDay.now();
  String notificationText = '';
  String notificationFrequency = 'Denně';
  String notificationType = 'Zvukové';
  String specialNotification = 'Ne';
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final TextEditingController _ownNotificationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = const AndroidInitializationSettings(
        'ic_launcher'); // Nastavte ikonu aplikace
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    localNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Prague'));
  }

  void _scheduleNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        selectedTime.hour, selectedTime.minute);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      'Flow-lístek',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await localNotificationsPlugin.zonedSchedule(
        0,
        'Nezapomeň na Flow-lístekk',
        selectedOption == 'Vlastní'
            ? _ownNotificationController.text
            : selectedOption,
        scheduledTime.isBefore(now)
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime,
        const NotificationDetails(
            android: AndroidNotificationDetails('0', 'pomoc',
                channelDescription: 'your channel pomoc')),
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    print(scheduledTime);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Nastavení notifikací úspěšně uloženo",
          style: TextStyle(
            color: Colors.black, // Text color
          ),
        ),
        duration: Duration(seconds: 3), // Duration of the SnackBar display
        backgroundColor: Color(0xFFEAEAEA),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      cancelText: 'zrušit',
      confirmText: 'potvrdit',
      helpText: 'vyberte čas',
      minuteLabelText: 'minuty',
      hourLabelText: 'hodiny',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
              primary: Colors.red,
              )
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true, textScaleFactor: 1.4),
            child: child!,
          )
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String formatTime24H(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
        title: const Text(
          'Nastavení upozornění',
          style: TextStyle(fontSize: 22, color: Color(0xFF61646B)),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF61646B),
          iconSize: 40, // Zvětšení velikosti ikony
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Čas Upozornění: ${formatTime24H(selectedTime)}',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(width: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        // Zmenšení šířky tlačítka na 40% šířky obrazovky a výšky na 50
                      ),
                      onPressed: () => _selectTime(context),
                      child: Text('Vybrat Čas'),
                    ),
                  ]),
                  SizedBox(height: 20),
                  FractionallySizedBox(
                    widthFactor: 0.8, // 80% šířky obrazovky
                    child: DropdownButton<String>(
                      itemHeight: 80,
                      isExpanded:
                          true, // Zajistí, že DropdownButton se rozšíří na maximální možnou šířku
                      value: selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue!;
                          isCustomOption = newValue == 'Vlastní';
                        });
                      },
                      items: <String>[
                        'Jaký byl tvůj dnešní den? Vzpomeneš si na 3 věci, které ti dnes vytvořily úsměv na tváři? Otevři svůj Flow-lístek!',
                        'Nemrač se! Rozhlédni se kolem sebe, uvědom si přítomnost. Co ti dneska udělalo radost? Zapiš si to do Flow-lístku!',
                        'Vlastní'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(
                                2), // Přidáváme padding pro lepší rozložení textu
                            constraints: BoxConstraints(
                              // Nastavíme minimální výšku pro každou položku
                              minHeight:
                                  80, // Minimální výška, upravte podle potřeby
                            ),
                            child: Text(
                              value,
                              maxLines: 3, // Povolíme až 3 řádky textu
                              overflow: TextOverflow
                                  .ellipsis, // Přidá "..." na konec, pokud text přetéká
                              softWrap: true, // Umožní textu zalomit řádky
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Zobrazit TextField pouze pokud je vybrána možnost "Vlastní"
                  if (isCustomOption)
                    TextField(
                      cursorColor: Color(0xFFE50E2B),
                      cursorWidth: 2,
                      controller: _ownNotificationController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color:
                                Color(0xFFE50E2B), // Barva ohraničení při psaní
                            width: 2.0, // Šířka ohraničení
                          ),
                        ),
                        hintText: 'Text upozornění',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Color(0xFFBCBCBC))),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (value) {},
                    ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: notificationType,
                    onChanged: (String? newValue) {
                      setState(() {
                        notificationType = newValue!;
                      });
                    },
                    items: <String>['Zvukové', 'Vibrační', 'Tiché']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      // Zmenšení šířky tlačítka na 40% šířky obrazovky a výšky na 50
                    ),
                    onPressed: _scheduleNotification,
                    child: Text('ULOŽIT NASTAVENÍ'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
