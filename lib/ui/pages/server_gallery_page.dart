import 'package:flutter/material.dart';
import 'package:pheco/main.dart';
import 'package:pheco/ui/pages/settings_page.dart';
import 'package:path/path.dart' as path;
import 'package:pheco/ui/shared/gallery_content.dart';
import 'package:pheco/ui/shared/gallery_drawer.dart';
import 'package:pheco/ui/shared/main_bottom_bar.dart';

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

  Widget _noConnectionScreen(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.red[400],
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "No connection to server",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                serverGallery.connectionError()!,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.white),
              ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Connected: ${nasClient.isConnected()}");
    if (nasClient.isConnected()) {
      print("Interface: ${nasClient.interface()}");
      nasClient.interface()?.listFoldersInDirRelative("/").then((e) {
        print("Folders");
        print(e);
      });
    }

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
        drawer: galleryDrawer(context, serverGallery.getFolderList(), (s) {
          setState(() {
            _selectedFolder = s;
          });
        }),
        body: serverGallery.connectionError() == null
            ? galleryContent(
                context,
                serverGallery.getFilesInFolder(_selectedFolder),
                _selectedFolder,
                GalleryType.serverOnly)
            : _noConnectionScreen(context),
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
