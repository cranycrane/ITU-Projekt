import 'package:flowlist/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'app_colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  String selectedOption =
      'Jaký byl tvůj dnešní den? Vzpomeneš si na 3 věci, které ti dnes vytvořily úsměv na tváři? Otevři svůj Flow-lístek!';
  bool isCustomOption = false;
  bool isLoading = true;

  late List<String> parts;
  late String? notificationTime;
  late TimeOfDay selectedTime;

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
    _getUserNotificationTime();

    var initializationSettingsAndroid = const AndroidInitializationSettings(
        'flowlist'); // Nastavte ikonu aplikace
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    localNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Prague'));
  }

  void _getUserNotificationTime() async {
    try {
      var userTime = await userController.getNotificationTime();
      setState(() {
        notificationTime = userTime ?? '00:00';
        parts = notificationTime!.split(':');
        selectedTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        isLoading = false;
      });

      selectedTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      String errorMessage = e.toString().split('Exception: ')[1];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Chyba: ${e.toString()}')));
    }
  }

  void _scheduleNotification() async {
    if (selectedTime.hour == 0 && selectedTime.minute == 0) {
      return;
    }
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        selectedTime.hour, selectedTime.minute);

    try {
      await userController.updateNotificationTime(selectedTime);

      await localNotificationsPlugin.zonedSchedule(
          0,
          'Nezapomeň na Flow-lístek',
          selectedOption == 'Vlastní'
              ? _ownNotificationController.text
              : selectedOption,
          scheduledTime.isBefore(now)
              ? scheduledTime.add(const Duration(days: 1))
              : scheduledTime,
          NotificationDetails(
              android: AndroidNotificationDetails('0', 'Flow-lístek',
                  icon: 'flowlist',
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: notificationType == 'Zvukové' ? true : false,
                  enableVibration:
                      notificationType == 'Vibrační' ? true : false,
                  visibility: NotificationVisibility.public)),
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

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
    } catch (e) {
      if (!context.mounted) return;
      String errorMessage = e.toString().split('Exception: ')[1];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Chyba: $errorMessage')));
    }
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
            )),
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(alwaysUse24HourFormat: true, textScaleFactor: 1.4),
              child: child!,
            ));
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String formatTime24H(TimeOfDay time) {
    if (time.hour == 0 && time.minute == 0) {
      return "Dosud nenastaveno";
    }
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return 'Každý den v: $hours:$minutes';
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
        body: isLoading
            ? Center(child: const CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'Čas Upozornění:\n${formatTime24H(selectedTime)}',
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 30),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  // Zmenšení šířky tlačítka na 40% šířky obrazovky a výšky na 50
                                ),
                                onPressed: () => _selectTime(context),
                                child: const Text('Vybrat Čas'),
                              ),
                            ]),
                        const SizedBox(height: 40),
                        const Text(
                          'Text upozornění:',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
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
                                  padding: const EdgeInsets.all(
                                      2), // Přidáváme padding pro lepší rozložení textu
                                  constraints: const BoxConstraints(
                                    // Nastavíme minimální výšku pro každou položku
                                    minHeight:
                                        80, // Minimální výška, upravte podle potřeby
                                  ),
                                  child: Text(
                                    value,
                                    maxLines: 3, // Povolíme až 3 řádky textu
                                    overflow: TextOverflow
                                        .ellipsis, // Přidá "..." na konec, pokud text přetéká
                                    softWrap:
                                        true, // Umožní textu zalomit řádky
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Zobrazit TextField pouze pokud je vybrána možnost "Vlastní"
                        if (isCustomOption)
                          TextField(
                            cursorColor: const Color(0xFFE50E2B),
                            cursorWidth: 2,
                            controller: _ownNotificationController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(
                                      0xFFE50E2B), // Barva ohraničení při psaní
                                  width: 2.0, // Šířka ohraničení
                                ),
                              ),
                              hintText: 'Text upozornění',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFBCBCBC))),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onSubmitted: (value) {},
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          'Způsob upozornění:',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            // Zmenšení šířky tlačítka na 40% šířky obrazovky a výšky na 50
                          ),
                          onPressed: _scheduleNotification,
                          child: const Text('ULOŽIT NASTAVENÍ'),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
