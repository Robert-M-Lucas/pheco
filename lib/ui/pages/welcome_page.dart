import 'package:flutter/material.dart';
import 'package:pheco/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int welcomeInfoVersion = 2;

Future<bool> shouldShowWelcomePage() async {
  final sp = await SharedPreferences.getInstance();
  var v = sp.getInt("welcomeVersion");
  if (v == null) {
    return true;
  }
  return v != welcomeInfoVersion;
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
                'Heading 1',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Text("Paragraph 1"),
              const Text("Paragraph 2"),
              Text(
                'Heading 2',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Text("Paragraph 3"),
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
                  (await SharedPreferences.getInstance())
                      .setInt("welcomeVersion", welcomeInfoVersion);
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
