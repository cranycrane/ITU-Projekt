import 'package:flutter/material.dart';
import 'flow.dart';
import 'diary_entries_loader.dart';
import 'diary_controller.dart';
import 'package:intl/intl.dart'; // Přidání pro formátování data
import 'messages_page.dart';
import 'user_profile.dart';
import 'psycho_overview.dart';
import 'calendar_client.dart';
import 'statistics_page.dart';

class PsychoEntryPage extends StatefulWidget {
  final UserProfile client;
  final DateTime? selectedDay;

  final int _selectedIndex = -1; // Index pro navigaci v BottomAppBar

  const PsychoEntryPage({Key? key, this.selectedDay, required this.client})
      : super(key: key);

  @override
  PsychoEntryPageState createState() => PsychoEntryPageState();
}

class PsychoEntryPageState extends State<PsychoEntryPage> {
  late DateTime selectedDate; // Přidáno pro sledování vybraného data
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  bool _isDataLoaded = false;
  bool dataFromBackend = true;
  late Future<FlowData?> _recordFuture;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDay ?? DateTime.now();
    _recordFuture = _loadData(selectedDate);
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  // Funkce pro načtení záznamů z deníku
  Future<FlowData?> _loadData(DateTime selectedDay) async {
    DiaryEntriesLoader loader = DiaryEntriesLoader(diaryController);
    return await loader.loadDiaryEntries(
        selectedDay, widget.client.userId.toString());
  }

  Future<bool> createEntry(FlowData record) async {
    try {
      // Zde předpokládáme, že `diaryController.createEntry(record)` vrací budoucnost (Future)
      await diaryController.createEntry(record);
      return true; // Úspěch
    } catch (e) {
      throw Exception('Chyba při vytváření záznamu: $e');
    }
  }

  Future<bool> deleteEntry() async {
    try {
      // Zde předpokládáme, že `diaryController.createEntry(record)` vrací budoucnost (Future)
      await diaryController.deleteEntry(selectedDate);
      return true; // Úspěch
    } catch (e) {
      throw Exception('Chyba při mazání záznamu: $e');
    }
  }

  void _changeDay(int days) {
    final DateTime newDate = selectedDate.add(Duration(days: days));

    // Check if the new date is in the future and if the selected date is not today
    if (newDate.isAfter(DateTime.now()) && selectedDate != DateTime.now()) {
      return; // Do nothing if trying to go into the future from a non-today date
    }
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
      _isDataLoaded = false;
      _recordFuture = _loadData(selectedDate);
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // Kdyby byla domovská stránka na indexu 0
        // Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        // Přechod na stránku pro vyhledávání
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const PsychoOverviewPage()));
        break;
      case 2:
        // PsychoUserPage
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CalendarClientPage(client: widget.client)));
        // Tady byste mohli implementovat přechod na stránku oznámení
        break;
      case 3:
        // Navigace na SettingsPage, pokud uživatel není již na této stránce

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MessagesPage(
                  toUserId: widget.client.userId.toString(),
                )));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StatisticsPage(
                  userId: widget.client.userId.toString(),
                )));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => _changeDay(-1),
            ),
            Text(
              formattedDate,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.black),
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IntrinsicHeight(
              // Tento widget zajistí, že obsah bude mít minimální výšku
              child: FutureBuilder<FlowData?>(
                future: _recordFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Došlo k chybě při načítání dat');
                  } else {
                    // Aktualizace textových polí podle načtených dat
                    if (!_isDataLoaded && snapshot.data != null) {
                      final data = snapshot.data;
                      _firstController.text = data?.record1 ?? '';
                      _secondController.text = data?.record2 ?? '';
                      _thirdController.text = data?.record3 ?? '';
                      _ratingController.text =
                          data?.score == -1 ? '' : data!.score!.toString();
                      _isDataLoaded = true;
                      if ((data?.record1.isEmpty ?? true) &&
                          (data?.record2.isEmpty ?? true) &&
                          (data?.record3.isEmpty ?? true) &&
                          (data?.score == null)) {
                        dataFromBackend = false;
                      }
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // Přidáno pro zarovnání
                      children: <Widget>[
                        const SizedBox(height: 10),
                        TextField(
                          readOnly: true,
                          controller: _firstController,
                          cursorColor: const Color(0xFFE50E2B),
                          cursorWidth: 2,
                          decoration: InputDecoration(
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            labelText: 'První dobrá věc...',
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 4),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Color(
                                    0xFFE50E2B), // Barva ohraničení při psaní
                                width: 2.0, // Šířka ohraničení
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          readOnly: true,
                          controller: _secondController,
                          cursorColor: const Color(0xFFE50E2B),
                          cursorWidth: 2,
                          decoration: InputDecoration(
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            labelText: 'Druhá dobrá věc...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Color(
                                    0xFFE50E2B), // Barva ohraničení při psaní
                                width: 2.0, // Šířka ohraničení
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          readOnly: true,
                          controller: _thirdController,
                          cursorColor: const Color(0xFFE50E2B),
                          cursorWidth: 2,
                          decoration: InputDecoration(
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            labelText: 'Třetí dobrá věc...',
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(width: 15),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Color(
                                    0xFFE50E2B), // Barva ohraničení při psaní
                                width: 2.0, // Šířka ohraničení
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Flexible(
                              child: Text(
                                'Jak bys ohodnotil/a svůj den?',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width:
                                  80, // Nastavení pevné šířky pro textové pole
                              child: TextField(
                                readOnly: true,
                                textAlign: TextAlign.center,
                                controller: _ratingController,
                                cursorColor: const Color(0xFFE50E2B),
                                cursorWidth: 2,
                                decoration: InputDecoration(
                                  floatingLabelStyle:
                                      const TextStyle(color: Colors.black),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Color(
                                          0xFFE50E2B), // Barva ohraničení při psaní
                                      width: 2.0, // Šířka ohraničení
                                    ),
                                  ),
                                  hintText: '/10',
                                  border: const OutlineInputBorder(),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          height: 70,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                      size: 35,
                      Icons.home,
                      color: widget._selectedIndex == 0
                          ? Colors.red
                          : Colors.grey),
                  onPressed: () => _onItemTapped(1),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Přidání akce, která se provede po kliknutí
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => CalendarClientPage(
                                  client: widget.client,
                                )), // Změňte na cílovou stránku
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 0),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          width: 2.0,
                          color: widget._selectedIndex == 1
                              ? const Color(0xFFE50E2B)
                              : Colors.grey,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Colors.grey[200],
                            child: widget.client.imageFile == null
                                ? const Icon(Icons.person, size: 60)
                                : ClipOval(
                                    child: Image.file(
                                    widget.client.imageFile!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )),
                          ),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  "${widget.client.firstName} ${widget.client.lastName}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.only(right: 5),
                  icon: Icon(
                      size: 35,
                      Icons.query_stats,
                      color: widget._selectedIndex == 2
                          ? Colors.red
                          : Colors.grey),
                  onPressed: () => _onItemTapped(4),
                ),
                IconButton(
                  padding: const EdgeInsets.only(right: 5),
                  icon: Icon(
                      size: 35,
                      Icons.message,
                      color: widget._selectedIndex == 2
                          ? Colors.red
                          : Colors.grey),
                  onPressed: () => _onItemTapped(3),
                ),
              ],
            ),
          )),
    );
  }
}
