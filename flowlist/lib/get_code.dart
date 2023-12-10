import 'package:flowlist/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'add_note.dart';
import 'psycho_controller.dart';

class PsychoUserPage extends StatefulWidget {
  const PsychoUserPage({Key? key}) : super(key: key);

  @override
  _PsychoUserPageState createState() => _PsychoUserPageState();
}

class _PsychoUserPageState extends State<PsychoUserPage> {
  bool isLoading = true;
  bool? hasPsychologist;
  String? pairingCode;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _getPairingCode();
  }

  void _getPairingCode() async {
    var userInfo = await psychoController
        .getPairingCode(); // Předpokládáme, že máte tuto funkci
    setState(() {
      hasPsychologist = userInfo['hasPsychologist'];
      pairingCode = userInfo['pairingCode'];
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Logika pro navigaci na různé stránky
    switch (index) {
      case 0:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;
      // Zde můžete přidat další navigaci pro Search, Notifications atd.
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 2:
      case 3:
        // Pro tyto indexy není třeba žádná akce, protože jsme již na stránce nastavení
        break;
    }
  }

  Widget _buildMessagesPage() {
    // Implementace UI pro zprávy s psychologem
    return Text("ahoj");
  }

  Widget _buildPairingPage(String? code) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Zajišťuje, že obsah je ve středu
          children: <Widget>[
            Text(
              'Váš párovací kód:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0), // Vytváří vertikální mezeru
            Text(
              code ??
                  "N/A", // Zobrazuje kód nebo "N/A", pokud kód není dostupný
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0), // Další vertikální mezera
            Text(
              'Tento kód slouží ke spárování se svým psychologem. Jeho sdílením souhlasíte s tím, že osoba, se kterou kód sdílíte, bude moci sledovat vaše záznamy a psát vám zprávy.',
              textAlign: TextAlign.center, // Zarovnává text na střed
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget content;
    if (hasPsychologist == true) {
      content = _buildMessagesPage();
    } else {
      content = _buildPairingPage(pairingCode);
    }
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(16.0), child: content),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.search,
                  color: _selectedIndex == 1 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), // Prostor pro Floating Action Button
            IconButton(
              icon: Icon(Icons.notifications_none,
                  color: _selectedIndex == 2 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(Icons.person_outline,
                  color: _selectedIndex == 3 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => NewEntryPage()));
          // Implementace akce pro Floating Action Button
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
