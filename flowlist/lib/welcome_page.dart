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
      appBar: AppBar(
        title: Text('Jednoduchá Obrazovka'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://placekitten.com/200/200', // URL obrázku
              width: 200, // Šířka obrázku
              height: 200, // Výška obrázku
            ),
            SizedBox(height: 20), // Mezera mezi obrázkem a textem
            Text(
              'Vítejte na demo stránce!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // Mezera mezi textem a tlačítkem
            ElevatedButton(
              onPressed: () {
                // Akce, která se vykoná po kliknutí na tlačítko
                print('Tlačítko bylo stisknuto');
              },
              child: Text('Klikněte zde'),
            ),
          ],
        ),
      ),
    );
  }
}
