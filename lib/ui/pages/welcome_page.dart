import 'package:flutter/material.dart';
import 'package:pheco/main.dart';
import 'package:pheco/ui/shared/info_content.dart';

bool shouldShowWelcomePage() {
  return settingsStore.welcomeVersion() != infoVersion;
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
      body: Scrollbar(
          child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: infoContent(context))),
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
                  await settingsStore.setWelcomeVersion(infoVersion);
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
