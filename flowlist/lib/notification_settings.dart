import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    var initializationSettingsAndroid =
        AndroidInitializationSettings('flowlist'); // Nastavte ikonu aplikace
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    localNotificationsPlugin.initialize(initializationSettings);
    /*
    */
  }

  void _scheduleNotification() async {
    var scheduledNotificationDateTime = DateTime.now()
        .add(Duration(hours: selectedTime.hour, minutes: selectedTime.minute));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotificationsPlugin.show(
      0,
      'Naplánované Upozornění',
      notificationText,
      //scheduledNotificationDateTime,
      platformChannelSpecifics,
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          toolbarHeight: 60,
          title: Text('Nastavení Upozornění'),
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
                        style: TextStyle(fontSize: 16)),
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
                    onPressed: () {
                      // Implementace uložení nastavení
                    },
                    child: Text('ULOŽIT NASTAVENÍ'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
