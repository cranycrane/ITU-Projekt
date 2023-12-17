import 'package:flowlist/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'add_note.dart';
import 'psycho_controller.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'app_colors.dart';

class PsychoUserPage extends StatefulWidget {
  final int _selectedIndex = 2;
  const PsychoUserPage({Key? key}) : super(key: key);

  @override
  PsychoUserPageState createState() => PsychoUserPageState();
}

class PsychoUserPageState extends State<PsychoUserPage> {
  bool isLoading = true;
  bool? hasPsychologist;
  String? pairingCode;

  @override
  void initState() {
    super.initState();
    _getPairingCode();
  }

  void _getPairingCode() async {
    var userInfo = await psychoController.getPairingCode();
    if (userInfo['hasPsychologist'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext newContext) =>
                MessagesPage(toUserId: userInfo['psychoId'].toString())));
      });
    } else {
      setState(() {
        hasPsychologist = userInfo['hasPsychologist'];
        pairingCode = userInfo['pairingCode'];
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;

      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SearchPage()));
        break;
      case 2:
        break;
      case 3:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  Widget _buildPairingPage(String? code) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Váš párovací kód:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              code ?? "N/A",
              style: const TextStyle(
                fontSize: 24.0,
                color: AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Tento kód slouží ke spárování se svým psychologem. Jeho sdílením souhlasíte s tím, že osoba, se kterou kód sdílíte, bude moci sledovat vaše záznamy a psát vám zprávy.',
              textAlign: TextAlign.center,
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
              iconSize: 35,
              icon: Icon(Icons.home,
                  color: widget._selectedIndex == 0
                      ? AppColors.red
                      : AppColors.middleGrey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.search,
                  color: widget._selectedIndex == 1
                      ? AppColors.red
                      : AppColors.middleGrey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.message,
                  color: widget._selectedIndex == 2
                      ? AppColors.red
                      : AppColors.middleGrey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.person_outline,
                  color: widget._selectedIndex == 3
                      ? AppColors.red
                      : AppColors.middleGrey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        child: const Icon(size: 35, Icons.add),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewEntryPage()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
