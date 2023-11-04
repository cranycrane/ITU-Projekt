// auth_page.dart

import 'package:flutter/material.dart';
import 'auth_controller.dart';
import 'calendar_screen.dart';

class AuthPage extends StatefulWidget {
  final AuthController controller;
  const AuthPage({super.key, required this.controller});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Přihlášení'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'zadejte@email.cz',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Heslo',
                hintText: 'zadejte heslo',
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _handleSignIn();
                    },
                    child: const Text('Přihlásit se'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      //_handleRegister();
                    },
                    child: const Text('Registrovat se'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignIn() async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      await widget.controller
          .signIn(_emailController.text, _passwordController.text);
      scaffold
          .showSnackBar(const SnackBar(content: Text('Úspěšně přihlášen!')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CalendarPage()),
      );
    } catch (e) {
      // TODO: zobrazit chybovou zprávu
      scaffold
          .showSnackBar(SnackBar(content: Text('Chyba při přihlášení: $e')));
    }
  }
/*
  void _handleRegister() async {
    try {
      await widget.controller
          .register(_emailController.text, _passwordController.text);
      // TODO: přesměrování na další stránku nebo zobrazení zprávy o úspěšné registraci
    } catch (e) {
      // TODO: zobrazit chybovou zprávu
    }
  }
*/
}
