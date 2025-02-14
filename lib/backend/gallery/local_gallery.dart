import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pheco/backend/gallery/gallery_interface.dart';

class LocalGallery extends GalleryInterface {
  List<String>? images;
  List<String>? folders;
  List<String>? activeImages;
  bool updating = false;
  static const MethodChannel platform =
      MethodChannel('com.example.pheco/channel');

  @override
  Future<void> initialiseIfUninitialised() async {
    if ((images == null || folders == null) && !updating) {
      update();
    }
  }

  @override
  Future<void> update() async {
    updating = true;

    final List<String> tImages =
        (await platform.invokeMethod('getImages') as List<Object?>).map((e) {
      return e as String;
    }).toList();

    Set<String> folderPaths = {};

    for (var p in tImages) {
      folderPaths.add(File(p).parent.path);
    }

    images = tImages;
    folders = folderPaths.toList();
    super.updateDependencies();
    updating = false;
  }

  @override
  List<String>? getFilesInFolder(String? folder) {
    if (folder == null) {
      return images;
    }

    return images?.where((p) {
      return File(p).parent.path == folder;
    }).toList();
  }

  @override
  List<String>? getFolderList() {
    return folders;
  }
}
