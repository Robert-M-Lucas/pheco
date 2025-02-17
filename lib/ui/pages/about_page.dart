import 'package:flutter/material.dart';
import 'package:pheco/main.dart';

import '../shared/info_content.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("App Info", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Scrollbar(
            child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: <Widget>[
                      Text(
                          "Version: v${packageInfo.version}/${packageInfo.buildNumber}"),
                      const Divider(),
                    ] +
                    infoContent(context))));
  }
}
