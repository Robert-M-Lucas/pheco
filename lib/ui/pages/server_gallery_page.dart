import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pheco/backend/gallery/gallery_interface.dart';
import 'package:pheco/main.dart';
import 'package:pheco/ui/pages/settings_page.dart';
import 'package:path/path.dart' as path;
import 'package:pheco/ui/shared/gallery_drawer.dart';
import 'package:pheco/ui/shared/main_bottom_bar.dart';

import '../shared/gallery_content.dart';

class ServerGalleryPage extends StatefulWidget {
  const ServerGalleryPage({super.key});

  @override
  State<StatefulWidget> createState() => _ServerGalleryPageState();
}

class _ServerGalleryPageState extends State<ServerGalleryPage> {
  String? _selectedFolder;

  @override
  void initState() {
    // loadFiles();
    serverGallery.registerUpdateCallback(() {
      setState(() {});
    }, () {
      return mounted;
    });
    serverGallery.initialiseIfUninitialised();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            "Server Gallery - ${(_selectedFolder == null) ? "All Images" : path.basename(_selectedFolder!)}",
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
        drawer: galleryDrawer(context, localGallery.getFolderList(), (s) { setState(() {
          _selectedFolder = s;
        }); }),
        body: galleryContent(context, localGallery.getFilesInFolder(_selectedFolder), _selectedFolder, GalleryType.serverOnly),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            localGallery.update();
          },
          tooltip: 'Refresh',
          child: const Icon(Icons.refresh),
        ),
        bottomNavigationBar: const MainBottomBar(
          type: GalleryType.serverOnly,
          enabled: true,
        ));
  }
}
