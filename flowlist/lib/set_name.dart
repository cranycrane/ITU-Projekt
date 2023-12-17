import 'package:flutter/material.dart';
import 'user_controller.dart';
import 'calendar_screen.dart';
import 'app_colors.dart';

class setNamePage extends StatefulWidget {
  const setNamePage({super.key});

  @override
  setNamePageState createState() => setNamePageState();
}

class setNamePageState extends State<setNamePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/setNamePage.png',
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            const SizedBox(height: 20),
            const Text(
              "Jak se jmenuješ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 40),
            TextField(
              cursorColor: AppColors.red,
              cursorWidth: 2,
              controller: _firstNameController,
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
                hintText: 'Křestní jméno',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: AppColors.middleGrey)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {},
            ),
            const SizedBox(height: 40.0),
            TextField(
              cursorColor: AppColors.red,
              cursorWidth: 2,
              controller: _lastNameController,
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
                hintText: 'Příjmení',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: AppColors.middleGrey, width: 4)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {},
            ),
            const SizedBox(height: 85.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                width: MediaQuery.of(context).size.height * 0.4,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await userController.updateUserName(
                          _firstNameController.text, _lastNameController.text);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Jméno úspěšně nastaveno')),
                      );
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const CalendarPage()));
                    } catch (e) {
                      if (!context.mounted) return;
                      String errorMessage =
                          e.toString().split('Exception: ')[1];
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Chyba: $errorMessage')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    backgroundColor: AppColors.red,
                  ),
                  child: const Text(
                    'DO APLIKACE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
