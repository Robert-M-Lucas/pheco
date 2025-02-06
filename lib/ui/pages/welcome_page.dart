import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int welcomeInfoVersion = 1;

Future<bool> showWelcomePage() async {
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
          title: const Text("App Info", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("App info will go here!"),
        ));
  }
}
