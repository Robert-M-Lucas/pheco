
abstract interface class NasConnectionInterface {
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

abstract interface class NasFileInterface {
  /// Returns a list of folders in the specified directory
  Future<List<String>?> listFoldersInDir(String dir);
}
