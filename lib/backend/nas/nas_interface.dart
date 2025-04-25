import 'package:flutter/foundation.dart';

abstract class NasConnectionInterface {
  /// Tests the local and public connection, raising a `SettingsException` on error
  /// and returning a `String` on a warning
  Future<String?> testConnectionSettings();

  /// Tries to connect through local and public connection, if either are disconnected
  Future<void> connect();

  /// Tests local and public connection, disconnecting either if they fail
  Future<void> testConnections();

  /// Disconnects local and public connection
  Future<void> disconnect();

  /// Returns whether there is a connection either through the local or public IP
  bool isConnected();

  NasFileInterface getFileInterface();
}

/// All paths relative to base folder
abstract class NasFileInterface {
  Future<bool> initialiseRootDir();

  String rootDirPath();

  Future<bool> dirExistsAbsolute(String dir);

  Future<bool> dirExistsRelative(String relativeDir) {
    if (kDebugMode && relativeDir.startsWith("/")) {
      throw Exception("Expected relative dir");
    }
    if (kDebugMode &&
        (!rootDirPath().startsWith("/") || !rootDirPath().endsWith("/"))) {
      throw Exception("Malformed rootDirPath");
    }
    return dirExistsAbsolute(rootDirPath() + relativeDir);
  }

  /// Creates the specified directory and all missing parent directories
  Future<bool> createAllDirsAbsolute(String dir);

  Future<bool> createAllDirsRelative(String relativeDir) {
    if (kDebugMode && relativeDir.startsWith("/")) {
      throw Exception("Expected relative dir");
    }
    if (kDebugMode &&
        (!rootDirPath().startsWith("/") || !rootDirPath().endsWith("/"))) {
      throw Exception("Malformed rootDirPath");
    }
    return createAllDirsAbsolute(rootDirPath() + relativeDir);
  }

  /// Returns a list of folders in the specified directory
  Future<List<String>?> listFoldersInDirRelative(String dir);

  Future<Stream<Uint8List>?> getFileRelative(String path);

  Future<bool> writeFileAbsolute(String path, Uint8List contents, bool create);

  Future<bool> writeFileRelative(
      String relativePath, Uint8List contents, bool create) {
    if (kDebugMode && relativePath.startsWith("/")) {
      throw Exception("Expected relative dir");
    }
    if (kDebugMode &&
        (!rootDirPath().startsWith("/") || !rootDirPath().endsWith("/"))) {
      throw Exception("Malformed rootDirPath");
    }
    return writeFileAbsolute(rootDirPath() + relativePath, contents, create);
  }

  Future<bool> appendFileAbsolute(String path, Uint8List contents);

  Future<bool> appendFileRelative(String relativePath, Uint8List contents) {
    if (kDebugMode && relativePath.startsWith("/")) {
      throw Exception("Expected relative dir");
    }
    if (kDebugMode &&
        (!rootDirPath().startsWith("/") || !rootDirPath().endsWith("/"))) {
      throw Exception("Malformed rootDirPath");
    }
    return appendFileAbsolute(rootDirPath() + relativePath, contents);
  }
}
