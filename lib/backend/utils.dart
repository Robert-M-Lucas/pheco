import 'dart:io';
import 'package:path/path.dart' as p;

import 'constants.dart';
import 'package:flutter/foundation.dart';

class SettingsException implements Exception {
  String cause;
  SettingsException(this.cause);
}

class ValidIp {
  const ValidIp(this.ip, this.port);

  final String ip;
  final int port;

  @override
  String toString() {
    return "$ip:$port";
  }
}

Future<T?> futureNullError<T>(Future<T> f) async {
  try {
    return await f.then((v) => v as T?).onError((e, st) {
      // print("FNE: $e");
      // print(st);
      return null;
    });
  } on Exception catch (e) {
    // print("FNE: $e");
    // print(StackTrace.current);
    return null;
  }
}

bool isPhecoFile(String fileNameOrPath) {
  final fileName = p.basename(fileNameOrPath);
  final sections = fileName.split(".");
  if (sections.length < 3) { return false; }
  return sections[sections.length - 2] == "pheco";
}

String addPhecoExtensionToFile(String fileNameOrPath) {
  final sections = fileNameOrPath.split(".");
  sections.insert(sections.length - 1, "pheco");
  return sections.join(".");
}

bool isSupportedFileExt(String fileNameOrPath) {
  return supportedFileExtensions.contains(p.extension(fileNameOrPath).toLowerCase());
}
class AsyncLock {
  bool _lock = false;

  Future<void> getLock() async {
    while (_lock) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _lock = true;
    return;
  }

  void releaseLock() {
    if (kDebugMode && !_lock) {
      throw Exception("Lock exception");
    }
    _lock = false;
  }
}

String removePreSlash(String path) {
  if (path.startsWith("/")) {
    return path.substring(1);
  }
  return path;
}