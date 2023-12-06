import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'flow.dart';
import 'diary_entries_loader.dart';
import 'diary_controller.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({Key? key}) : super(key: key);

  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

/*
TODO: Napojit pridavani zaznamu
*/
class _NewEntryPageState extends State<NewEntryPage> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();

  int _selectedIndex = -1; // Index pro navigaci v BottomAppBar

  FlowData? record;

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //_loadRecord();
  }

  void _loadRecord(DateTime selectedDay) async {
    DiaryEntriesLoader loader = DiaryEntriesLoader(diaryController);

    //record = loader.loadDiaryEntries(selectedDay);
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
    final double bottomInset = MediaQuery.of(context)
        .viewInsets
        .bottom; // výška klávesnice nebo dalšího dolního obsahu
    final double screenHeight =
        MediaQuery.of(context).size.height - statusBarHeight - bottomInset;
    const double bottomBarHeight = kBottomNavigationBarHeight;

    // Celková výška, kterou je třeba zabrat, aby se obsah nezobrazoval pod klávesnicí
    final double bodyHeight = screenHeight - bottomBarHeight;

    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: bodyHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  maxLines: 7,
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
                  maxLines: 7,
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
                  maxLines: 7,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Akce pro uložení dat
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('ULOŽIT'),
                ),
              ],
            ),
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
