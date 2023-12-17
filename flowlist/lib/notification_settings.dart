/// Aplikace Flow-List
/// FIT VUT, ITU - Tvorba uzivatelskych rozhrani
/// Autor: Jakub Jerabek (xjerab28)
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
  bool wantsNotifications = true;

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

    // ikona aplikace
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('flowlist');
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
          .showSnackBar(SnackBar(content: Text('Chyba: $errorMessage')));
    }
  }

  void _scheduleNotification() async {
    if (selectedTime.hour == 0 && selectedTime.minute == 0) {
      return;
    }
    if (!wantsNotifications) {
      // Zrušení všech plánovaných notifikací
      await localNotificationsPlugin.cancelAll();
      await userController.updateNotificationTime(null);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Notifikace úspešně zrušeny",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          duration: Duration(seconds: 3),
          backgroundColor: AppColors.lightGrey,
        ),
      );
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
                  styleInformation: BigTextStyleInformation(
                      selectedOption == 'Vlastní'
                          ? _ownNotificationController.text
                          : selectedOption),
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
          duration: Duration(seconds: 3),
          backgroundColor: AppColors.lightGrey,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Chyba: ${e.toString()}')));
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
              primary: AppColors.red,
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
            style: TextStyle(fontSize: 22, color: AppColors.darkGrey),
          ),
          backgroundColor: Colors.white,
          toolbarHeight: 60,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.darkGrey,
            iconSize: 40,
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
                        SwitchListTile(
                          title: const Text('Povolit upozornění'),
                          value: wantsNotifications,
                          onChanged: (bool value) {
                            setState(() {
                              wantsNotifications = value;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'Čas Upozornění:\n${formatTime24H(selectedTime)}',
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 30),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red,
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
                            isExpanded: true,
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
                                  padding: const EdgeInsets.all(2),
                                  constraints: const BoxConstraints(
                                    minHeight: 80,
                                  ),
                                  child: Text(
                                    value,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (isCustomOption)
                          TextField(
                            cursorColor: AppColors.red,
                            cursorWidth: 2,
                            controller: _ownNotificationController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: AppColors.red,
                                  width: 2.0,
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
                            backgroundColor: AppColors.red,
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
