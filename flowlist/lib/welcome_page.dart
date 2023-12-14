import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://i.imgur.com/OHnXo9J.png', // URL obrázku
               width: MediaQuery.of(context).size.width,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'CO JE TO FLOW-LÍSTEK',
                    style: TextStyle(
                      fontSize: 24, // Zvýraznění velikosti písma
                      fontWeight: FontWeight.bold, // Zvýraznění tučným písmem
                      color: Colors.black, // Barva textu
                    ),
                  ),
                  SizedBox(height: 16.0), // Odstup mezi textem
                  Text(
                    'FLOW-LÍSTEK byl poprvé zmíněn v knize Konec prokrastinace, kterou napsal Petr Ludwig. Slouží jako nástroj, který pomáhá s osobní produktivitou a spokojeností člověka.\n\nJe to obdoba deníku, který si každý den otevřeš a zapíšeš si 3 pozitivní věci, které se ti během dne staly, ať už to bude cokoliv. Všechno od úsměvu slečny na ulici, přes dobrý oběd po výhru ve sportce se počítá. Každý den, 3 věci.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0), // Nastavte vertikální padding pro tlačítko
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFE50E2B), // Barva pozadí tlačítka
                  onPrimary: Colors.white, // Barva textu tlačítka
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0), // Padding uvnitř tlačítka
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0), // Zaoblení tlačítka
                  ),
                ),
                onPressed: () {
                  // TODO: Implementovat funkci tlačítka
                },
                child: Text(
                  'POKRAČOVAT',
                  style: TextStyle(
                    fontSize: 20, // Přizpůsobte velikost písma dle vašeho designu
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
