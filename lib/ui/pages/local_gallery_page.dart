import 'package:flutter/material.dart';
import 'package:pheco/main.dart';
import 'package:pheco/ui/pages/settings_page.dart';
import 'package:path/path.dart' as path;
import 'package:pheco/ui/shared/gallery_content.dart';
import 'package:pheco/ui/shared/gallery_drawer.dart';
import 'package:pheco/ui/shared/main_bottom_bar.dart';

class LocalGalleryPage extends StatefulWidget {
  const LocalGalleryPage({super.key});

  @override
  State<StatefulWidget> createState() => _LocalGalleryPageState();
}

class _LocalGalleryPageState extends State<LocalGalleryPage> {
  String? _selectedFolder;

  @override
  void initState() {
    localGallery.registerUpdateCallback(() {
      setState(() {});
    }, () {
      return mounted;
    });
    localGallery.initialiseIfUninitialised();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            "Local Gallery - ${(_selectedFolder == null) ? "All Images" : path.basename(_selectedFolder!)}",
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
        drawer: galleryDrawer(context, localGallery.getFolderList(), (s) {
          setState(() {
            _selectedFolder = s;
          });
        }),
        body: galleryContent(
            context,
            localGallery.getFilesInFolder(_selectedFolder),
            _selectedFolder,
            GalleryType.local),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            localGallery.update();
          },
          tooltip: 'Refresh',
          child: const Icon(Icons.refresh),
        ),
        bottomNavigationBar: const MainBottomBar(
          type: GalleryType.local,
          enabled: true,
        ));
  }
}
