import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'welcome_page_2.dart';
import 'app_colors.dart';

class WelcomePage extends StatefulWidget {
  bool onlyLooking;
  WelcomePage({super.key, required this.onlyLooking});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
          Image.asset(
            'assets/whatIsFlowlist.png',
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(0.0),
            child: Text(
              'CO JE TO FLOW-LÍSTEK?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'FLOW-LÍSTEK byl poprvé zmíněn v knize Konec prokrastinace, kterou napsal Petr Ludwig. Slouží jako nástroj, který pomáhá s osobní produktivitou a spokojeností člověka.\n\nJe to obdoba deníku, který si každý den otevřeš a zapíšeš si 3 pozitivní věci, které se ti během dne staly, ať už to bude cokoliv. Všechno od úsměvu slečny na ulici, přes dobrý oběd po výhru ve sportce se počítá. Každý den, 3 věci.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const WelcomePage2()));
              },
              child: const Text(
                'POKRAČOVAT',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    )));
  }
}
