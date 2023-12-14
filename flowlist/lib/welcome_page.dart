import 'package:flutter/material.dart';
import 'welcome_page_2.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder( // Use LayoutBuilder to get parent container size
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth, // Max width constraint
                  ),
                  child: Image.network(
                    'https://i.imgur.com/UBF5Ij6.png', // URL obrázku
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FittedBox( // Scales text to fit its parent
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'CO JE TO FLOW-LÍSTEK',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                      backgroundColor: const Color(0xFFE50E2B),
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => const WelcomePage2()));
                      // TODO: Implementovat funkci tlačítka
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
          );
        },
      ),
    );
  }
}
