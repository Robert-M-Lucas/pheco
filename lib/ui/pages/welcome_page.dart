import 'package:flutter/material.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';
import 'package:pheco/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int welcomeInfoVersion = 4;

bool shouldShowWelcomePage() {
  return settingsStore.welcomeVersion() != welcomeInfoVersion;
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void goToMainPage() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => mainPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title:
            const Text("Welcome Page", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(loremIpsum(paragraphs: 3)),
              const Padding(padding: EdgeInsets.all(7.0)),
              Text(
                'Compression',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(loremIpsum(paragraphs: 2)),
            ],
          )),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  goToMainPage();
                },
                child: const Text('Ok'),
              ),
              TextButton(
                onPressed: () async {
                  await settingsStore.setWelcomeVersion(welcomeInfoVersion);
                  goToMainPage();
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
