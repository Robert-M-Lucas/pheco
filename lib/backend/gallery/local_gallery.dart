import 'dart:io';

import 'package:pheco/backend/gallery/gallery_interface.dart';
import 'package:pheco/main.dart';

class LocalGallery extends GalleryInterface {
  List<String>? _images;
  List<String>? _folders;
  List<String>? _activeImages;
  bool _updating = false;

  @override
  Future<void> initialiseIfUninitialised() async {
    if ((_images == null || _folders == null) && !_updating) {
      update();
    }
  }

  @override
  Future<void> update() async {
    _updating = true;

    final List<String> tImages =
        (await platformChannel.invokeMethod('getImages') as List<Object?>)
            .map((e) {
      return e as String;
    }).toList();

    Set<String> folderPaths = {};

    for (var p in tImages) {
      folderPaths.add(File(p).parent.path);
    }

    _images = tImages;
    _folders = folderPaths.toList();
    super.updateDependencies();
    _updating = false;
  }

  @override
  List<String>? getFilesInFolder(String? folder) {
    if (folder == null) {
      return _images;
    }

    return _images?.where((p) {
      return File(p).parent.path == folder;
    }).toList();
  }

  @override
  List<String>? getFolderList() {
    return _folders;
  }
}
