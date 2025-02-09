import 'dart:io';

import 'package:flutter/material.dart';

enum GalleryType {
  local,
  serverOnly
}

Widget galleryContent(BuildContext context, List<String>? imageUris, String? selectedFolder, GalleryType galleryType) {
  return Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: (imageUris == null)
            ? <Widget>[
          Text(
            galleryType == GalleryType.local
                ? 'Loading device images'
                : 'Loading server-only images',
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
                          return selectedFolder == null
                              ? true
                              : (File(e).parent.path ==
                              selectedFolder);
                        }).map((e) {
                          final split = e.split(".");
                          final pheco = split.length > 2 &&
                              split[split.length - 2] == "pheco";
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
              ))
        ]),
  );
}