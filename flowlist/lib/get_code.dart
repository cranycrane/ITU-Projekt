import 'package:flowlist/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'add_note.dart';
import 'psycho_controller.dart';
import 'messages_page.dart';

class PsychoUserPage extends StatefulWidget {
  const PsychoUserPage({Key? key}) : super(key: key);

  @override
  PsychoUserPageState createState() => PsychoUserPageState();
}

class PsychoUserPageState extends State<PsychoUserPage> {
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
    if (userInfo['hasPsychologist'] == true) {
      // Pokud má uživatel přiděleného psychologa, přesměrujte ho na stránku zpráv
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext newContext) =>
                MessagesPage(toUserId: userInfo['psychoId'].toString())));
      });
    } else {
      // Uložte kód a aktualizujte UI
      setState(() {
        hasPsychologist = userInfo['hasPsychologist'];
        pairingCode = userInfo['pairingCode'];
        isLoading = false;
      });
    }
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
            .push(MaterialPageRoute(builder: (context) => const SearchPage()));
        break;
      case 2:
      case 3:
        // Pro tyto indexy není třeba žádná akce, protože jsme již na stránce nastavení
        break;
    }
  }

  Widget _buildPairingPage(String? code) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Zajišťuje, že obsah je ve středu
          children: <Widget>[
            const Text(
              'Váš párovací kód:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0), // Vytváří vertikální mezeru
            Text(
              code ??
                  "N/A", // Zobrazuje kód nebo "N/A", pokud kód není dostupný
              style: const TextStyle(
                fontSize: 24.0,
                color: Color(0xFFE50E2B),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0), // Další vertikální mezera
            const Text(
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

    Widget content = _buildPairingPage(pairingCode);

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
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewEntryPage()));
          // Implementace akce pro Floating Action Button
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
