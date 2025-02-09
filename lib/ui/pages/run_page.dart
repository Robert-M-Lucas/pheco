import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pheco/backend/actions/action_interface.dart';
import 'package:pheco/main.dart';
import 'package:pheco/ui/pages/settings_page.dart';
import 'package:pheco/ui/shared/main_bottom_bar.dart';

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  State<RunPage> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
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

  // Future<void> recompressFiles() async {
  //   consoleText("DEBUG: Only working in testing folder");
  //   consoleText("DEBUG: Using fixed compression quality");
  //   String folder = "/storage/emulated/0/Pictures/Testing";
  //
  //   consoleText("| Getting image list");
  //   Stopwatch s2 = Stopwatch()..start();
  //   final List<dynamic> imagesU = await platform.invokeMethod('getImages');
  //   s2.stop();
  //   print("Done - ${s2.elapsedMilliseconds}ms");
  //
  //   consoleText("| Processing ${imagesU.length} images and deleting existing");
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   List<String> images = [];
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
  //
  //     images.add(i.toString());
  //   }
  //
  //   consoleText("| Compressing ${images.length} images");
  //   await Future.delayed(const Duration(milliseconds: 500));
  //
  //   for (var i in images) {
  //     consoleText("Compressing '$i'");
  //     File file = File(i);
  //     var result = await FlutterImageCompress.compressWithFile(
  //       file.absolute.path,
  //       quality: 40,
  //     );
  //
  //     if (result == null) {
  //       consoleText("Compression Failed");
  //       continue;
  //     }
  //
  //     var split = i.split(".");
  //     split.insert(split.length - 1, "pheco");
  //     final newName = split.join(".");
  //     consoleText("Saving '$newName'");
  //     await saveFile(result, newName);
  //     await platform.invokeMethod('rescanMedia', {'path': newName});
  //   }
  // }

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

  Future<void> saveFile(Uint8List uint8List, String filePath) async {
    // Request storage permission (needed for Android 10 and below)
    if (await Permission.storage.request().isDenied) {
      print("Storage permission denied");
      return;
    }

    // Write the file
    File file = File(filePath);
    final result = await file.writeAsBytes(uint8List);
    print(result);

    print("File saved to: $filePath");
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
            child: ListView(
                children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
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
                    (serverGallery.connectionError() == null
                        ? []
                        : [
                            Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Center(
                                  child: Text(
                                      "No server connection: ${serverGallery.connectionError()!}",
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
                        enabled: !_runningTask,
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
                    }).toList()
                // ListTile(
                //   leading: const Icon(Icons.compress),
                //   title: const Text('Compress Files'),
                //   enabled: !_runningTask,
                //   subtitle: const Text(
                //       'Compress uncompressed files and transfer originals to server - this is the action that can be scheduled in the settings.'),
                //   onTap: () async {
                //     consoleText("> [Not Implemented ] Compress Files");
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.refresh),
                //   title: const Text('Recompress Files'),
                //   enabled: !_runningTask,
                //   subtitle: const Text(
                //       'Replace all existing compressed files with recompressed ones. Recommended after changing compression settings.'),
                //   onTap: () async {
                //     setState(() {
                //       _runningTask = true;
                //     });
                //     consoleText("> Recompressing Files");
                //     await recompressFiles();
                //     consoleText("Done!");
                //     setState(() {
                //       _runningTask = false;
                //     });
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.delete_forever),
                //   title: const Text('Delete Compressed'),
                //   enabled: !_runningTask,
                //   subtitle: const Text(
                //       'Delete all compressed files. Sets \'Upload\' to \'Manual\' to prevent automatic recompression.'),
                //   onTap: () async {
                //     setState(() {
                //       _runningTask = true;
                //     });
                //     consoleText("> Deleting Compressed Files");
                //     await deleteCompressedFiles();
                //     consoleText("Done!");
                //     setState(() {
                //       _runningTask = false;
                //     });
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.install_mobile),
                //   title: const Text('Redownload Originals'),
                //   enabled: !_runningTask,
                //   subtitle: const Text(
                //       'Download all original files (replacing compressed ones). Sets \'Upload\' to \'Manual\' to prevent automatic recompression.'),
                //   onTap: () {
                //     consoleText("> [Not Implemented] Redownload Originals");
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.difference),
                //   title: const Text('Validate Files'),
                //   enabled: !_runningTask,
                //   subtitle: const Text(
                //       'Ensures all files on server have a compressed version on device. Notifies you of any compressed files that are not on the server.'),
                //   onTap: () {
                //     consoleText("> [Not Implemented] Validate Files");
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.image_search),
                //   title: const Text('Rescan MediaStore'),
                //   enabled: !_runningTask,
                //   subtitle: const Text(
                //       'Rescans the device for new images Android may not have found yet.'),
                //   onTap: () async {
                //     setState(() {
                //       _runningTask = true;
                //     });
                //     consoleText("> Rescanning MediaStore (can take up to a minute)");
                //     consoleText("Note: This task has no progress indication");
                //     Stopwatch s1 = Stopwatch()..start();
                //     await platform.invokeMethod('rescanMedia');
                //     s1.stop();
                //     consoleText("Done - ${s1.elapsedMilliseconds}ms");
                //     setState(() {
                //       _runningTask = false;
                //     });
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.print),
                //   title: const Text('Print Test'),
                //   subtitle: const Text('Print Test'),
                //   enabled: !_runningTask,
                //   onTap: () async {
                //     setState(() {
                //       _runningTask = true;
                //     });
                //     consoleText("> Starting print test...");
                //     await Future.delayed(const Duration(seconds: 1));
                //     for (var i = 0; i < 100; i++) {
                //       consoleText(
                //           "[PrintTest]: ${Random().nextInt(4294967296)}${Random().nextInt(4294967296)}${Random().nextInt(4294967296)}");
                //       await Future.delayed(
                //           Duration(milliseconds: Random().nextInt(100)));
                //     }
                //     await Future.delayed(const Duration(seconds: 2));
                //     consoleText("Done!");
                //     setState(() {
                //       _runningTask = false;
                //     });
                //   },
                // ),]
                )),
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
