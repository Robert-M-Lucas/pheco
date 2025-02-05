import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pheco/ui/pages/settings_page.dart';
import 'package:pheco/ui/shared/main_bottom_bar.dart';

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  State<RunPage> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  final platform = const MethodChannel('com.example.pheco/channel');
  List<String> _output = [
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "> Ready to run action"
  ];

  bool _runningTask = false;

  void consoleText(String text) {
    print("[consoleText]: $text");
    setState(() {
      _output.removeAt(0);
      _output.add(text);
    });
  }

  @override
  void initState() {
    // Broken
    // platform.setMethodCallHandler((MethodCall call) async {
    //   if (call.method == 'updateProgress') {
    //     print(call.arguments);
    //     consoleText(call.arguments["value"]);
    //   }
    //   print(call);
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Run Actions", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Settings cog icon
            onPressed: _runningTask ? null : () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
            child: ListView(children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Center(
                child: Text(
              'Actions',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 100, 100, 100)),
            )),
          ),
          const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Text('Do close the app while actions are in progress!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    )),
              )),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Recompress Files'),
            enabled: !_runningTask,
            subtitle: const Text(
                'Replace all existing compressed files with recompressed ones. Recommended after changing compression settings.'),
            onTap: () {
              consoleText("> [Not Implemented] Recompress Files");
            },
          ),
          ListTile(
            leading: const Icon(Icons.install_mobile),
            title: const Text('Redownload Originals'),
            enabled: !_runningTask,
            subtitle: const Text(
                'Download all original files (replacing compressed ones). Sets \'Upload\' to \'Manual\' to prevent automatic recompression.'),
            onTap: () {
              consoleText("> [Not Implemented] Redownload Originals");
            },
          ),
          ListTile(
            leading: const Icon(Icons.difference),
            title: const Text('Validate Files'),
            enabled: !_runningTask,
            subtitle: const Text(
                'Ensures all files on server have a compressed version on device. Notifies you of any compressed files that are not on the server.'),
            onTap: () {
              consoleText("> [Not Implemented] Validate Files");
            },
          ),
            ListTile(
              leading: const Icon(Icons.image_search),
              title: const Text('Rescan MediaStore'),
              enabled: !_runningTask,
              subtitle: const Text(
                  'Rescans the device for new images Android may not have found yet.'),
              onTap: () async {
                setState(() {
                  _runningTask = true;
                });
                consoleText("> Rescanning MediaStore (can take up to a minute)");
                consoleText("Note: This task has no progress indication");
                Stopwatch s1 = Stopwatch()..start();
                await platform.invokeMethod('rescanMedia');
                s1.stop();
                consoleText("Done - ${s1.elapsedMilliseconds}ms");
                setState(() {
                  _runningTask = false;
                });
              },
            ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print Test'),
            subtitle: const Text('Print Test'),
            enabled: !_runningTask,
            onTap: () async {
              setState(() {
                _runningTask = true;
              });
              consoleText("> Starting print test...");
              await Future.delayed(const Duration(seconds: 1));
              for (var i = 0; i < 100; i++) {
                consoleText("[PrintTest]: ${Random().nextInt(4294967296)}${Random().nextInt(4294967296)}${Random().nextInt(4294967296)}");
                await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
              }
              await Future.delayed(const Duration(seconds: 2));
              consoleText("Done!");
              setState(() {
                _runningTask = false;
              });
            },
          ),
        ])),
        Container(
          width: double.infinity,
          color: Colors.black,
          child: Text(
            _output.join("\n"),
            style: const TextStyle(color: Colors.white, fontFamily: "monospace"),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        )
      ]),
      bottomNavigationBar: MainBottomBar(type: null, enabled: !_runningTask),
    );
  }
}
