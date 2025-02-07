import 'dart:io';

import 'package:pheco/backend/gallery/gallery_interface.dart';

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

  @override
  void update() {
    // TODO: implement update
    throw UnimplementedError();
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

  @override
  String noReturnReason(String? folder) {
    // TODO: implement noReturnReason
    throw UnimplementedError();
  }
}

