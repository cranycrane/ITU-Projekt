import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'flow.dart';
import 'diary_entries_loader.dart';
import 'diary_controller.dart';
import 'package:intl/intl.dart'; // Přidání pro formátování data

class NewEntryPage extends StatefulWidget {
  final DateTime? selectedDay;

  NewEntryPage({Key? key, this.selectedDay}) : super(key: key);

  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

/*
TODO: Napojit pridavani zaznamu
*/
class _NewEntryPageState extends State<NewEntryPage> {
  late DateTime selectedDate; // Přidáno pro sledování vybraného data
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDay ?? DateTime.now();
  }

  int _selectedIndex = -1; // Index pro navigaci v BottomAppBar

  FlowData? record;

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _changeDay(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 2:
      case 3:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // final double bottomInset = MediaQuery.of(context).viewInsets.bottom; // výška klávesnice nebo dalšího dolního obsahu
    //final double screenHeight = MediaQuery.of(context).size.height - statusBarHeight - bottomInset;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final DateFormat formatter = DateFormat('EEEE d.M.yyyy', 'cs_CZ');

    String formattedDate = formatter.format(selectedDate).toUpperCase();
    //final double bottomBarHeight = kBottomNavigationBarHeight;

    // Celková výška, kterou je třeba zabrat, aby se obsah nezobrazoval pod klávesnicí
    //final double bodyHeight = screenHeight - bottomBarHeight;

    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Zarovnání obsahu na obě strany
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left,
                  color: Colors.black), // Icon barva nastavena na černou
              onPressed: () => _changeDay(-1),
            ),
            Text(
              formattedDate, // Použití pomocné funkce pro zobrazení data
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black), // Text barva nastavena na černou
            ),
            IconButton(
              icon: Icon(Icons.chevron_right,
                  color: Colors.black), // Icon barva nastavena na černou
              onPressed: () => _changeDay(1),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0, // Odstranění stínu AppBaru
        backgroundColor: Colors.transparent, // Transparentní AppBar
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: keyboardHeight > 0
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Přidáno pro zarovnání
            children: <Widget>[
              SizedBox(height: statusBarHeight),
              TextField(
                controller: _firstController,
                decoration: InputDecoration(
                  labelText: 'První položka',
                  border: const OutlineInputBorder(),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _secondController,
                decoration: InputDecoration(
                  labelText: 'Druhá položka',
                  border: const OutlineInputBorder(),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _thirdController,
                decoration: InputDecoration(
                  labelText: 'Třetí položka',
                  border: const OutlineInputBorder(),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      'Jak bys ohodnotil svůj den?',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 80, // Nastavení pevné šířky pro textové pole
                    child: TextField(
                      controller: _ratingController,
                      decoration: InputDecoration(
                        hintText: '/10',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                // Tlačítka vedle sebe s mezerou
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Akce pro smazání dat
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey, // Barva tlačítka SMAZAT
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // Bez zaoblení
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('SMAZAT'),
                    ),
                  ),
                  SizedBox(width: 8), // Mezera mezi tlačítky
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Akce pro uložení dat
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // Barva tlačítka ULOŽIT
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // Bez zaoblení
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('ULOŽIT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
              icon: Icon(Icons.settings,
                  color: _selectedIndex == 3 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: isKeyboardVisible
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.add),
              onPressed: () {
                // Akce pro FloatingActionButton
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
