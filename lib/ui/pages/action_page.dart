import 'package:flutter/material.dart';
import 'package:pheco/backend/actions/action_interface.dart';
import 'package:pheco/main.dart';
import 'package:pheco/ui/pages/settings_page.dart';
import 'package:pheco/ui/shared/main_bottom_bar.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  final List<String> _output = [
    "",
    "",
    "",
    "",
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
    localGallery.registerUpdateCallback(() {
      setState(() {});
    }, () {
      return mounted;
    });
    localGallery.initialiseIfUninitialised();

    // serverGallery.registerUpdateCallback(() {
    //   setState(() {});
    // }, () {
    //   return mounted;
    // });
    // serverGallery.initialiseIfUninitialised();

    super.initState();
  }

  // Future<void> deleteCompressedFiles() async {
  //   consoleText("DEBUG: Only working in testing folder");
  //   String folder = "/storage/emulated/0/Pictures/Testing";
  //
  //   consoleText("| Getting image list");
  //   Stopwatch s2 = Stopwatch()..start();
  //   final List<dynamic> imagesU = await platform.invokeMethod('getImages');
  //   s2.stop();
  //   consoleText("Done - ${s2.elapsedMilliseconds}ms");
  //
  //   consoleText("| Processing ${imagesU.length} images and deleting existing");
  //   for (var i in imagesU) {
  //     final s = i.toString();
  //     if (File(i.toString()).parent.path != folder) {
  //       continue;
  //     }
  //
  //     final split = s.split(".");
  //     final pheco = split.length > 2 && split[split.length - 2] == "pheco";
  //     if (pheco) {
  //       consoleText("Removing '$s'");
  //       await platform.invokeMethod('deleteMediaFile', {'path': s});
  //       continue;
  //     }
  //   }
  // }

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
            onPressed: _runningTask
                ? null
                : () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
                  },
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
            child: Scrollbar(
                child: ListView(
                    children: [
                          const Padding(
                            padding: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 8.0),
                            child: Center(
                                child: Text(
                              'Actions',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 100, 100, 100)),
                            )),
                          ) as Widget,
                        ] +
                        (settingsStore.validData()
                            ? []
                            : [
                                Padding(
                                    padding: EdgeInsets.only(
                                        bottom:
                                            // serverGallery.connectionError() ==
                                            //         null
                                            //     ? 8.0
                                            //     : 0.00),
                                            8.0),
                                    child: const Center(
                                      child: Text("Settings aren't configured",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          )),
                                    )),
                              ]) +
                        (nasClient.isConnected()
                            ? []
                            : [
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Center(
                                      child: Text(
                                          "No server connection: ${nasClient.noConnectionReason()}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          )),
                                    )),
                              ]) +
                        allActions.map((e) {
                          return ListTile(
                            leading: e.getIcon(),
                            title: Text(e.getName()),
                            enabled: !(_runningTask ||
                                (e.requireValidSettings() &&
                                    !settingsStore.validData()) ||
                                (e.requireServerConnection() &&
                                    !nasClient.isConnected())),
                            subtitle: Text(e.getSubtitle()),
                            onTap: () async {
                              setState(() {
                                _runningTask = true;
                              });
                              consoleText("");
                              consoleText("> Running ${e.getName()}");
                              Stopwatch s = Stopwatch()..start();
                              await e.run(consoleText);
                              s.stop();
                              consoleText(
                                  "> Completed in ${s.elapsedMilliseconds}ms");
                              setState(() {
                                _runningTask = false;
                              });
                            },
                          ) as Widget;
                        }).toList()))),
        Container(
          width: double.infinity,
          color: Colors.black,
          child: Text(
            _output.join("\n"),
            style: const TextStyle(
                color: Colors.white, fontFamily: "monospace", fontSize: 11),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        )
      ]),
      bottomNavigationBar: MainBottomBar(type: null, enabled: !_runningTask),
    );
  }
}
