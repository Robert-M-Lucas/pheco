
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    loadFolders();
    super.initState();
  }

  Future<void> ransackFiles() async {
    // print("Started ransack");
    //
    // Stopwatch t = Stopwatch()..start();
    //
    // print("Getting external directory");
    // // Get the directory where your app can store files
    // final directory = await getExternalStorageDirectory();
    //
    // print("Listing files");
    // // List all files in the directory
    // final dir = Directory(directory?.path ?? '');
    // // final dir = Directory("/storage/emulated/0");
    //
    // print("Found dir ${dir.path}");
    //
    // List<FileSystemEntity> files = dir.listSync(recursive: true, followLinks: false);
    //
    // print("Filtering");
    // // Filter files by the specified extension
    // List<FileSystemEntity> filteredFiles = files.where((file) {
    //   return file is File && file.path.endsWith(".jpg");
    // }).toList();
    //
    // t.stop();
    //
    // print("Found files in ${t.elapsed.inMilliseconds}ms");
    //
    // for (var item in filteredFiles) {
    //   print(item.path);
    // }
    print("Start");
    Stopwatch s = Stopwatch()..start();

    const platform = MethodChannel('com.example.pheco/channel');
    try {
      final List<dynamic> imagesU = await platform.invokeMethod('getImages');
      List<String> images = [];

      for (var i in imagesU) {
        images.add(i.toString());
      }

      print("Images:\n${images.length}");
    } on PlatformException catch (e) {
      print("Failed to get images: '${e.message}'.");
    }
    s.stop();

    print("Done - ${s.elapsedMilliseconds}ms");
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
          children: <Widget>[
            const Text(
              'Gallery content will go here',
            ),
            Text(
              'Sit tight',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
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
