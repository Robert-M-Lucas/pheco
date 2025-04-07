import 'dart:io';
import 'package:path/path.dart' as p;

import 'constants.dart';

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
      print("FNE: $e");
      print(st);
      return null;
    });
  } on Exception catch (e) {
    print("FNE: $e");
    print(StackTrace.current);
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