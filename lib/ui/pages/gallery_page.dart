import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:media_store_plus/media_store_plus.dart';
import 'package:pheco/ui/pages/settings_page.dart';

enum GalleryType { local, serverOnly }

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.type});

  final GalleryType type;

  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Widget>? folders;
  List<String>? imageUris;

  @override
  void initState() {
    loadFolders();
    super.initState();
  }

  Future<void> ransackFiles() async {
    print("Start");

    setState(() {
      imageUris = null;
    });

    Stopwatch s = Stopwatch()..start();

    const platform = MethodChannel('com.example.pheco/channel');
    try {
      final List<dynamic> imagesU =
          await platform.invokeMethod('getImages', {'count': 1000});
      List<String> images = [];

      for (var i in imagesU) {
        images.add(i.toString());
      }

      print("Images:\n${images.length}");
      print("Sample:\n${images[0]}");

      s.stop();

      print("Done - ${s.elapsedMilliseconds}ms");

      // var d = await mediaStorePlugin.getFilePathFromUri(uriString: images[0]);
      // print(d);

      // List<String> imagesM = [];
      // for (var i in images) {
      //   imagesM.add((await mediaStorePlugin.getFilePathFromUri(uriString: i))!);
      // }

      setState(() {
        imageUris = images;
      });

      print("State set");

      print("Testing compression");

      File file = File(images[12]);
      var result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 80,
      );
      print(file.lengthSync());
      print(result?.length);

      final ratio = (result!.length.toDouble()) / (file.lengthSync().toDouble());
      print("Ratio: $ratio");

      print("Compression done");

      print("Saving file");
      saveFile(result, "compress.pheco.jpg");

    } on PlatformException catch (e) {
      print("Failed to get images: '${e.message}'.");
    }
  }

  Future<void> saveFile(Uint8List uint8List, String fileName) async {
    // Request storage permission (needed for Android 10 and below)
    if (await Permission.storage.request().isDenied) {
      print("Storage permission denied");
      return;
    }

    // Let the user pick a directory
    String? outputDir = await FilePicker.platform.getDirectoryPath();
    if (outputDir == null) {
      // User canceled the file picker
      print("User cancelled picking");
      return;
    }

    print("Saving...");
    // Define the full path
    String filePath = '$outputDir/$fileName';

    // Write the file
    File file = File(filePath);
    final result = await file.writeAsBytes(uint8List);
    print(result);

    print("File saved to: $filePath");
  }

  String getTitle() {
    switch (widget.type) {
      case GalleryType.local:
        return "Local Gallery";
      case GalleryType.serverOnly:
        return "Server-Only Gallery";
    }
  }

  void navigateToOther(GalleryType other) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          GalleryPage(type: other),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: 0.0, end: 1.0);
        final opacityAnimation = animation.drive(tween);
        return FadeTransition(opacity: opacityAnimation, child: child);
      },
    ));
  }

  Future<void> loadFolders() async {
    print("Async loading folders...");
    await Future.delayed(const Duration(seconds: 5));
    List<Widget> sampleFolders = [];

    for (int i = 0; i < 100; i++) {
      sampleFolders.add(ListTile(
          leading: const Icon(Icons.folder),
          title: Text('Folder $i'),
          onTap: () {
            Navigator.pop(context);
          }));
    }

    if (mounted) {
      setState(() {
        folders = sampleFolders;
      });
      print("Set folder list");
    } else {
      print("Failed to set folder list as widget no longer exists");
    }
  }

  Widget drawer(BuildContext context) {
    List<Widget> dFolders;

    dFolders = folders ??
        [
          const ListTile(
            leading: Icon(Icons.folder),
            title: Text('Loading folders...'),
          )
        ];

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                    Container(
                      height: 80, // Custom height
                      color: Theme.of(context).colorScheme.primary,
                      alignment: Alignment.center,
                      child: const Text('Pheco',
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                    ) as Widget
                  ] +
                  dFolders,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          getTitle(),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: drawer(context),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (imageUris == null)
                ? <Widget>[
                    const Text(
                      'Gallery content will go here',
                    ),
                    Text(
                      'Sit tight',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ]
                : <Widget>[
                    Expanded(
                        child: CustomScrollView(
                      primary: false,
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverGrid.count(
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2,
                              children: imageUris!.map((e) {
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.green[100],
                                  child: Image.file(
                                    File(e),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList()),
                        ),
                      ],
                    ))
                  ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Button");
          ransackFiles();
        },
        tooltip: 'Ransack',
        child: const Icon(Icons.folder),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: SizedBox.expand(
                child: IconButton(
                  icon: const Icon(Icons.home, size: 30),
                  onPressed: () {
                    if (widget.type != GalleryType.local) {
                      navigateToOther(GalleryType.local);
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: SizedBox.expand(
                child: IconButton(
                  icon: const Icon(Icons.storage, size: 30),
                  onPressed: () {
                    if (widget.type != GalleryType.serverOnly) {
                      navigateToOther(GalleryType.serverOnly);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
