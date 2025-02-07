import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pheco/backend/gallery/gallery_interface.dart';
import 'package:pheco/main.dart';
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
  String? _selectedFolder;

  GalleryInterface gallery() {
    switch (widget.type) {

      case GalleryType.local:
        return localGallery;
      case GalleryType.serverOnly:
        return serverGallery;
    }
  }

  @override
  void initState() {
    // loadFiles();
    gallery().registerUpdateCallback(() { setState(() {}); }, () { return mounted; });
    gallery().initialiseIfUninitialised();
    super.initState();
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

    dFolders = gallery().getFolderList()?.map((f) {
      return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(path.basename(f)),
          subtitle: Text(f),
          onTap: () {
            setState(() {
              _selectedFolder = f;
            });
            Navigator.pop(context);
          });
    }).toList() ??
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
    final imageUris = gallery().getFilesInFolder(_selectedFolder);
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (imageUris == null)
              ? <Widget>[
                  Text(
                    widget.type == GalleryType.local
                        ? 'Device images will go here'
                        : 'Server-only images will go here',
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
                            children: imageUris.where((e) {
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
            gallery().update();
          },
          tooltip: 'Refresh',
          child: const Icon(Icons.refresh),
        ),
        bottomNavigationBar: MainBottomBar(
          type: widget.type,
          enabled: true,
        ));
  }
}
