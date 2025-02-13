import 'dart:io';

import 'package:pheco/backend/gallery/gallery_interface.dart';
import 'package:pheco/main.dart';

class ServerGallery extends GalleryInterface {
  List<String>? images;
  List<String>? folders;
  bool updating = false;

  @override
  void initialiseIfUninitialised() {
    if ((images == null || folders == null) && !updating) {
      update();
    }
  }

  bool isInitialised() {
    return false;
  }

  @override
  Future<void> update() async {
    // TODO: implement update
    // throw UnimplementedError();
  }

  String? connectionError() {
    if (nasClient.isConnected()) {
      return null;
    }
    return nasClient.noConnectionReason();
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
