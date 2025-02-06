import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pheco/ui/pages/settings_page.dart';
import 'package:path/path.dart' as path;
import 'package:pheco/ui/shared/main_bottom_bar.dart';

enum GalleryType { local, serverOnly }

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.type});

  final GalleryType type;

  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Widget>? _folders;
  List<String>? _imageUris;
  String? _selectedFolder;

  @override
  void initState() {
    loadFiles();
    super.initState();
  }

  Future<void> loadFiles() async {
    setState(() {
      _imageUris = null;
    });

    const platform = MethodChannel('com.example.pheco/channel');
    try {
      print("Getting image list");
      Stopwatch s2 = Stopwatch()..start();
      final List<dynamic> imagesU = await platform.invokeMethod('getImages');
      s2.stop();
      print("Done - ${s2.elapsedMilliseconds}ms");

      List<String> images = [];

      for (var i in imagesU) {
        images.add(i.toString());
      }

      setState(() {
        _imageUris = images;
      });

      print("State set");

      print("Generating Folders");
      List<Widget> folderWidgets = [
        ListTile(
            leading: const Icon(Icons.image),
            title: const Text("All Images"),
            onTap: () {
              setState(() {
                _selectedFolder = null;
              });
              Navigator.pop(context);
            })
      ];
      Set<String> folderPaths = {};

      for (var p in images) {
        folderPaths.add(File(p).parent.path);
      }

      for (var f in folderPaths) {
        print(f);
        folderWidgets.add(ListTile(
            leading: const Icon(Icons.folder),
            title: Text(path.basename(f)),
            subtitle: Text(f),
            onTap: () {
              setState(() {
                _selectedFolder = f;
              });
              Navigator.pop(context);
            }));
      }

      if (mounted) {
        setState(() {
          _folders = folderWidgets;
        });
        print("Set folder list");
      } else {
        print("Failed to set folder list as widget no longer exists");
      }

    } on PlatformException catch (e) {
      print("Failed to get images: '${e.message}'.");
    }
  }

  String getTitle() {
    switch (widget.type) {
      case GalleryType.local:
        return "Local Gallery - ${(_selectedFolder == null) ? "All Images" : path.basename(_selectedFolder!)}";
      case GalleryType.serverOnly:
        return "Server-Only Gallery";
    }
  }

  Widget drawer(BuildContext context) {
    List<Widget> dFolders;

    dFolders = _folders ??
        [
          const ListTile(
            leading: Icon(Icons.folder),
            title: Text('Loading folders...'),
            enabled: false,
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

  Widget galleryContent(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (_imageUris == null)
              ? <Widget>[
                Text(
                    widget.type == GalleryType.local ? 'Device images will go here' : 'Server-only images will go here',
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
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            crossAxisCount: 2,
                            children: _imageUris!.where((e) {
                              return _selectedFolder == null
                                  ? true
                                  : (File(e).parent.path == _selectedFolder);
                            }).map((e) {
                              final split = e.split(".");
                              final pheco = split.length > 2 &&
                                  split[split.length - 2] == "pheco";
                              return Container(
                                padding: const EdgeInsets.all(4),
                                color:
                                    pheco ? Colors.green[300] : Colors.red[300],
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
          actions: [
            IconButton(
              icon: const Icon(Icons.settings), // Settings cog icon
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsPage()));
              },
            ),
          ],
        ),
        drawer: drawer(context),
        body: galleryContent(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Button");
            loadFiles();
          },
          tooltip: 'Ransack',
          child: const Icon(Icons.refresh),
        ),
        bottomNavigationBar: MainBottomBar(
          type: widget.type,
          enabled: true,
        ));
  }
}
