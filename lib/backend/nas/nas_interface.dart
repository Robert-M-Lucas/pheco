import 'dart:typed_data';

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

  Future<bool> dirExistsRelative(String dir);

  /// Creates the specified directory and all missing parent directories
  Future<bool> createAllDirsAbsolute(String dir);

  /// Returns a list of folders in the specified directory
  Future<List<String>?> listFoldersInDirRelative(String dir);
  
  Future<Stream<Uint8List>?> getFileRelative(String path);

  Future<bool> writeFileRelative(String path, Uint8List contents);
}
