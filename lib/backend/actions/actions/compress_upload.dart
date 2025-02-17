import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pheco/backend/actions/action_interface.dart';
import 'package:pheco/main.dart';

class CompressUploadAction implements ActionInterface {
  const CompressUploadAction();

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
    final int interval = nonPheco.length ~/ 10;
    printer("Interval: $interval");
    var step = 1;

    for (var i in nonPheco) {
      if (compressed != 0 && compressed % interval == 0) {
        printer("Compressed/Uploaded ${step * 10}%");
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

      final uploadResult = await nasClient.sendFileToServer(
          await file.readAsBytes(), file.absolute.path);
      if (!uploadResult) {
        printer("Failed to upload '$i'");
      } else {
        await file.delete();
      }
    }
  }

  @override
  bool requireServerConnection() => true;

  @override
  bool requireValidSettings() => true;

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
}
