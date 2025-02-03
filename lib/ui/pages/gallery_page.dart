import 'package:flutter/material.dart';
import 'package:pheco/ui/pages/settings_page.dart';

enum GalleryType { local, serverOnly }

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.type});

  final GalleryType type;

  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String getTitle() {
    switch (widget.type) {
      case GalleryType.local:
        return "Local Gallery";
      case GalleryType.serverOnly:
        return "Server-Only Gallery";
    }
  }

  void navigateToOther(GalleryType other) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            GalleryPage(type: other)));
  }

  Widget drawer(BuildContext context) {
    List<Widget> sample_folders = [];
    
    for (int i = 0; i < 100; i ++) {
      sample_folders.add(
        ListTile(
            leading: const Icon(Icons.folder),
            title: Text('Folder $i'),
            onTap: () {
              Navigator.pop(context);
        })
      );
    }
    
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration:
                      BoxDecoration(color: Theme.of(context).colorScheme.tertiary),
                  child: const Text('Pheco',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                ) as Widget,
              ] + sample_folders,
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage())
              );
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(getTitle()),
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
                  icon: const Icon(Icons.account_tree, size: 30),
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
