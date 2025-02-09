import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../pages/settings_page.dart';

Widget galleryDrawer(BuildContext context, List<String>? folderList,
    Function(String?) setFolder) {
  List<Widget> dFolders = folderList?.map((f) {
        return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(path.basename(f)),
            subtitle: Text(f),
            onTap: () {
              setFolder(f);
              Navigator.pop(context);
            }) as Widget;
      }).toList() ??
      <Widget>[
        const ListTile(
          leading: Icon(Icons.folder),
          title: Text('Loading folders...'),
          enabled: false,
        )
      ];

  if (dFolders.length > 1) {
    dFolders.insert(
        0,
        ListTile(
            leading: const Icon(Icons.folder),
            title: const Text("All Folders"),
            subtitle: const Text("All images"),
            onTap: () {
              setFolder(null);
              Navigator.pop(context);
            }) as Widget);
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
                dFolders,
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        ),
      ],
    ),
  );
}
