import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int welcomeInfoVersion = 1;

Future<bool> shouldShowWelcomePage() async {
  final sp = await SharedPreferences.getInstance();
  var v = sp.getInt("welcomeVersion");
  if (v == null) {
    return true;
  }
  return v == welcomeInfoVersion;
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Welcome Page", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Information will go here"),
        ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // Handle "Ok" action
                },
                child: const Text('Ok'),
              ),
              TextButton(
                onPressed: () {
                  // Handle "Don't show again" action
                },
                child: const Text("Don't show again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
