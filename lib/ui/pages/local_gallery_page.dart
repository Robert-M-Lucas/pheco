import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pheco/backend/utils.dart';
import 'package:pheco/main.dart';
import 'package:pheco/ui/pages/settings_page.dart';
import 'package:path/path.dart' as path;
import 'package:pheco/ui/shared/gallery_content.dart';
import 'package:pheco/ui/shared/gallery_drawer.dart';
import 'package:pheco/ui/shared/gallery_refresh_button.dart';
import 'package:pheco/ui/shared/main_bottom_bar.dart';


class LocalGalleryPage extends StatefulWidget {
  const LocalGalleryPage({super.key});

  @override
  State<StatefulWidget> createState() => _LocalGalleryPageState();
}

class _LocalGalleryPageState extends State<LocalGalleryPage> {
  String? _selectedFolder;
  bool _firstLoad = true;

  bool _reloading = false;

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
    final folderList = localGallery.getFolderList();
    if (_firstLoad && folderList != null) {
      if (folderList.isNotEmpty) {
        setState(() {
          _selectedFolder = folderList[0];
        });
      }
      setState(() {
        _firstLoad = false;
      });
    }

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
        body: _galleryContent(
            context,
            localGallery.getFilesInFolder(_selectedFolder),
            _selectedFolder),
        floatingActionButton: refreshButton(_reloading, () async {
          if (!mounted) {
            return;
          }
          setState(() {
            _reloading = true;
          });
          await localGallery.update();
          if (!mounted) {
            return;
          }
          setState(() {
            _reloading = false;
          });
        }),
        bottomNavigationBar: const MainBottomBar(
          type: GalleryType.local,
          enabled: true,
        ));
  }

  Widget _galleryContent(BuildContext context, List<String>? imageUris,
      String? selectedFolder) {
    final portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisCount = portrait ? 2 : 4;

    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (imageUris == null)
              ? <Widget>[
            const Text('Loading device images'
            ),
            Text(
              'Sit tight',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ]
              : (imageUris.isEmpty)
              ? <Widget>[
            const Text("No images in this folder"),
          ]
              : <Widget>[
            Expanded(
                child: Scrollbar(
                    child: CustomScrollView(
                      primary: false,
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverGrid.count(
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              crossAxisCount: crossAxisCount,
                              children: imageUris.where((e) {
                                return selectedFolder == null
                                    ? true
                                    : (File(e).parent.path == selectedFolder);
                              }).map((e) {
                                final pheco = isPhecoFile(e);
                                return Container(
                                  padding: const EdgeInsets.all(4),
                                  color: pheco
                                      ? Colors.green[300]
                                      : Colors.red[300],
                                  child: Image.file(
                                    File(e),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList()),
                        ),
                      ],
                    )))
          ]),
    );
  }

}
