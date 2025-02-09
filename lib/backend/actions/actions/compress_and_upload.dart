import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pheco/backend/actions/action_interface.dart';
import 'package:pheco/main.dart';

class CompressAndUploadAction implements ActionInterface {
  const CompressAndUploadAction();

  @override
  Icon getIcon() => const Icon(Icons.compress);

  @override
  String getName() => "Compress & Upload";

  @override
  String getSubtitle() =>
      "Compress uncompressed files and transfer originals to server - this is the action that can be scheduled in the settings.";

  @override
  Future<void> run(Function(String) printer) async {
    printer("DEBUG: Only working in testing folder");

    printer("Fetching local images");
    var allFiles = localGallery.getFilesInFolder(null);

    const maxTime = 6000;
    const delayPer = 1000;
    final s = Stopwatch()..start();
    while (allFiles == null && s.elapsedMilliseconds < maxTime) {
      printer("Image loading still in progress, waiting ${delayPer}ms");
      await Future.delayed(const Duration(milliseconds: delayPer));
      allFiles = localGallery.getFilesInFolder(null);
    }

    if (allFiles == null) {
      printer(
          "Stopping - images didn't load after maximum time (${maxTime}ms)");
      return;
    }

    printer("Found ${allFiles.length} images");

    final nonPheco = allFiles.where((e) {
      final split = e.split(".");
      final pheco = split.length > 2 && split[split.length - 2] == "pheco";
      return !pheco;
    }).toList();

    printer("Found ${nonPheco.length} uncompressed images");

    var compressedFiles = [];
    var compressed = 0;
    final int interval = (nonPheco.length / 10).toInt();
    printer("Interval: $interval");
    var step = 1;

    for (var i in nonPheco) {
      if (compressed != 0 && compressed % interval == 0) {
        printer("Compressed ${step * 10}%");
        step += 1;
      }
      compressed += 1;

      File file = File(i);
      var result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 40,
      );

      if (result == null) {
        printer("Failed to compress '$i'");
        continue;
      }

      var split = i.split(".");
      split.insert(split.length - 1, "pheco");
      final newName = split.join(".");
      compressedFiles.add(newName);
      final saveSuccess = await _saveFile(result, newName, printer);
      if (!saveSuccess) {
        continue;
      }
      await platformChannel.invokeMethod('rescanMedia', {'path': newName});
    }
  }

  Future<bool> _saveFile(
      Uint8List uint8List, String filePath, Function(String) printer) async {
    // Request storage permission (needed for Android 10 and below)
    if (await Permission.storage.request().isDenied) {
      printer("Storage permission denied");
      return false;
    }

    // Write the file
    File file = File(filePath);
    final result = await file.writeAsBytes(uint8List);
    return true;
  }

  @override
  bool requireServerConnection() => true;

  @override
  bool requireValidSettings() => true;
}

// Future<void> recompressFiles() async {
//   consoleText("DEBUG: Only working in testing folder");
//   consoleText("DEBUG: Using fixed compression quality");
//   String folder = "/storage/emulated/0/Pictures/Testing";
//
//   consoleText("| Getting image list");
//   Stopwatch s2 = Stopwatch()..start();
//   final List<dynamic> imagesU = await platform.invokeMethod('getImages');
//   s2.stop();
//   print("Done - ${s2.elapsedMilliseconds}ms");
//
//   consoleText("| Processing ${imagesU.length} images and deleting existing");
//   await Future.delayed(const Duration(milliseconds: 500));
//   List<String> images = [];
//   for (var i in imagesU) {
//     final s = i.toString();
//     if (File(i.toString()).parent.path != folder) {
//       continue;
//     }
//
//     final split = s.split(".");
//     final pheco = split.length > 2 && split[split.length - 2] == "pheco";
//     if (pheco) {
//       consoleText("Removing '$s'");
//       await platform.invokeMethod('deleteMediaFile', {'path': s});
//       continue;
//     }
//
//     images.add(i.toString());
//   }
//   consoleText("| Compressing ${images.length} images");
//   await Future.delayed(const Duration(milliseconds: 500));
//
//   for (var i in images) {
//     consoleText("Compressing '$i'");
//     File file = File(i);
//     var result = await FlutterImageCompress.compressWithFile(
//       file.absolute.path,
//       quality: 40,
//     );
//
//     if (result == null) {
//       consoleText("Compression Failed");
//       continue;
//     }
//
//     var split = i.split(".");
//     split.insert(split.length - 1, "pheco");
//     final newName = split.join(".");
//     consoleText("Saving '$newName'");
//     await saveFile(result, newName);
//     await platform.invokeMethod('rescanMedia', {'path': newName});
//   }
// }
