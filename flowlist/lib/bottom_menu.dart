import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'settings_page.dart';
import 'search_page.dart'; // Předpokládáme, že máte soubor search_page.dart
import 'add_note.dart';
import 'get_code.dart';
import 'diary_controller.dart';
import 'diary_entries_loader.dart';
import 'flow.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  void _onItemTapped(int index) {
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.home,
                color: widget.selectedIndex == 0 ? Colors.red : Colors.grey),
            onPressed: () => _onItemTapped(0),
          ),
          IconButton(
            icon: Icon(Icons.search,
                color: widget.selectedIndex == 1 ? Colors.red : Colors.grey),
            onPressed: () => _onItemTapped(1),
          ),
          const SizedBox(width: 48),
          IconButton(
            icon: Icon(Icons.notifications_none,
                color: widget.selectedIndex == 2 ? Colors.red : Colors.grey),
            onPressed: () => _onItemTapped(2),
          ),
          IconButton(
            icon: Icon(Icons.person_outline,
                color: widget.selectedIndex == 3 ? Colors.red : Colors.grey),
            onPressed: () => _onItemTapped(3),
          ),
        ],
      ),
    );
  }
}
