import 'package:flutter/material.dart';
import 'user_controller.dart';
import 'calendar_screen.dart';

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
        // Přidáno SingleChildScrollView
        padding: const EdgeInsets.all(60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://jakub-jerabek.cz/flowlist/assets/setNamePage.png', // URL obrázku
              width: 200, // Šířka obrázku
              height: 200, // Výška obrázku
            ),
            const SizedBox(height: 20), // Mezera mezi obrázkem a textem
            const Text(
              "Jak se jmenuješ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 40), // Mezera mezi obrázkem a textem
            TextField(
              cursorColor: const Color(0xFFE50E2B),
              cursorWidth: 2,
              controller: _firstNameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFE50E2B), // Barva ohraničení při psaní
                    width: 2.0, // Šířka ohraničení
                  ),
                ),
                hintText: 'Křestní jméno',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFFBCBCBC))),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {},
            ),
            const SizedBox(height: 40.0),
            TextField(
              cursorColor: const Color(0xFFE50E2B),
              cursorWidth: 2,
              controller: _lastNameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFE50E2B), // Barva ohraničení při psaní
                    width: 2.0, // Šířka ohraničení
                  ),
                ),
                hintText: 'Příjmení',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFFBCBCBC), width: 4)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {},
            ),
            const SizedBox(height: 85.0),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SizedBox(
                width: 160,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await userController.updateUserName(
                          '${_firstNameController.text} ${_lastNameController.text}');
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
                    backgroundColor: const Color(0xFFE50E2B),
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
/*
  void _handleSignIn() async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      await widget.controller
          .signIn(_emailController.text, _passwordController.text);
      scaffold
          .showSnackBar(const SnackBar(content: Text('Úspěšně přihlášen!')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CalendarPage()),
      );
    } catch (e) {
      // TODO: zobrazit chybovou zprávu
      scaffold
          .showSnackBar(SnackBar(content: Text('Chyba při přihlášení: $e')));
    }
  }
  */
}
