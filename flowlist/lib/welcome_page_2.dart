import 'package:flutter/material.dart';
import 'set_name.dart';
import 'app_colors.dart';

class WelcomePage2 extends StatefulWidget {
  const WelcomePage2({super.key});

  @override
  _WelcomePageState2 createState() => _WelcomePageState2();
}

class _WelcomePageState2 extends State<WelcomePage2> {
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
            'assets/whyFlowlist.png',
            width: MediaQuery.of(context).size.width * 0.6,
          ),
          SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'A PROČ BYCH SI HO MĚL PSÁT?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 1.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text:
                        'Díky pravidelnému zaznamenávání pozitivních událostí se učíme zlepšovat orientaci na naši minulost. To nám pomáhá se lépe vypořádat s úzkostí, pocity méněcennosti, či případně s příznaky deprese.\n\nZároveň jako lidé máme tendenci hodnotit náš život na základě aktuální nálady. Díky Flow-lístku se můžeme podívat nazpět a získat tak okamžitou zpětnou vazbu, že bylo líp!\n\n',
                  ),
                  TextSpan(
                    text: 'Tak co, jdeš do toho?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const setNamePage()));
              },
              child: const Text(
                'JDU DO TOHO',
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
