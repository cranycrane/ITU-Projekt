import 'package:flowlist/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'auth_page.dart';
import 'search_page.dart';
import 'add_note.dart';
import 'calendar_screen.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 3; // Index pro nastavení stránky

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Logika pro navigaci na různé stránky
    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CalendarPage()));
        break;
      // Zde můžete přidat další navigaci pro Search, Notifications atd.
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 2:
      case 3:
        // Pro tyto indexy není třeba žádná akce, protože jsme již na stránce nastavení
        break;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40), // Výchozí ikona avatara
              backgroundColor: Colors.grey[200], // Nastavení barvy pozadí avatara
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Jan Novák',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                'jan.novak@seznam.cz',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: false,
              onChanged: (bool value) {
                // Implementace přepnutí Dark Mode
              },
            ),
            // Další prvky nastavení
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton(
                child: Text('ODHLÁSIT SE'),
                onPressed: () {
                  // Implementace odhlášení
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  minimumSize: Size(double.infinity, 50), // Nastavení šířky na šířku obrazovky a výšku na 50
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.search, color: _selectedIndex == 1 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            SizedBox(width: 48), // Prostor pro Floating Action Button
            IconButton(
              icon: Icon(Icons.notifications_none, color: _selectedIndex == 2 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: _selectedIndex == 3 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: () {
    // Získání aktuálního data

    // Navigace na NewEntryPage s aktuálním datem
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewEntryPage(selectedDay: DateTime.now()
        ),
      ),
    );
          // Implementace akce pro Floating Action Button
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
