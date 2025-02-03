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
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          GalleryPage(type: other),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: 0.0, end: 1.0);
        final opacityAnimation = animation.drive(tween);
        return FadeTransition(opacity: opacityAnimation, child: child);
      },
    ));
  }

  Widget drawer(BuildContext context) {
    List<Widget> sampleFolders = [];

    for (int i = 0; i < 100; i++) {
      sampleFolders.add(ListTile(
          leading: const Icon(Icons.folder),
          title: Text('Folder $i'),
          onTap: () {
            Navigator.pop(context);
          }));
    }

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
                  sampleFolders,
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
