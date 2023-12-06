import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'package:intl/intl.dart'; // Přidání pro formátování data

class NewEntryPage extends StatefulWidget {
  final DateTime selectedDay;

  NewEntryPage({Key? key, required this.selectedDay}) : super(key: key);

  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late DateTime selectedDate; // Přidáno pro sledování vybraného data
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();


  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDay;
  }

  int _selectedIndex = -1; // Index pro navigaci v BottomAppBar

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
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CalendarPage()));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 2:
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
    }
  }

  

  

 @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;

    String formattedDate =
        DateFormat('EEEE d.M.yyyy', 'cs_CZ').format(selectedDate).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => _changeDay(-1),
            ),
            Text(
              formattedDate,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: Colors.black),
              onPressed: () => _changeDay(1),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      resizeToAvoidBottomInset: true,

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: statusBarHeight),
              TextField(
                controller: _firstController,
                decoration: InputDecoration(
                  labelText: 'První položka',
                  border: OutlineInputBorder(),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                maxLines: 5,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _secondController,
                decoration: InputDecoration(
                  labelText: 'Druhá položka',
                  border: OutlineInputBorder(),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                maxLines: 5,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _thirdController,
                decoration: InputDecoration(
                  labelText: 'Třetí položka',
                  border: OutlineInputBorder(),
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
                    width: 80,
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
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Akce pro smazání dat
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // Upravit podle potřeby
                      ),
                      child: Text('SMAZAT'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Akce pro uložení dat
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // Upravit podle potřeby
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
            SizedBox(width: 48),
            IconButton(
              icon: Icon(Icons.notifications_none, color: _selectedIndex == 2 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: _selectedIndex == 3 ? Colors.red : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),

      floatingActionButton: keyboardHeight > 0
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(Icons.add),
              onPressed: () {
                // Akce pro FloatingActionButton
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
