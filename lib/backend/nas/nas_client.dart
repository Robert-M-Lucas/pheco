import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:pheco/backend/nas/nas_interface.dart';
import 'package:pheco/backend/utils.dart';
import 'package:pheco/main.dart';
import 'package:tuple/tuple.dart';

import 'nas_utils.dart';

const hashFile = ".file-hashes";

const int connectionRetryMs = 10000;
const String connectionToServerFailed = "Connection to server failed";
const String badConnectionSettings = "Bad connection settings";
const String setUpConnectionInSettings = "Set up connection in settings";

class NasClient {
  NasClient() {
    Future.delayed(const Duration(milliseconds: connectionRetryMs), () {
      _retryConnection();
    });
  }

  Set<int> _existingFiles = {};
  Set<int> existingFiles() => Set.unmodifiable(_existingFiles);

  final AsyncLock _serverHashFileLock = AsyncLock();

  String _noConnectionReason = "";
  String noConnectionReason() => _noConnectionReason;

  final List<Tuple2<Function(), bool Function()>> listeners = [];

  NasConnectionInterface? _connection;

  NasFileInterface? interface() =>
      isConnected() ? _connection!.getFileInterface() : null;

  void addUpdateListener(Function() permanentListener) {
    listeners.add(Tuple2(permanentListener, () {
      return true;
    }));
  }

  void addTempUpdateListener(
      Function() tempListener, bool Function() aliveCheck) {
    listeners.add(Tuple2(tempListener, aliveCheck));
  }

  bool isConnected() => _connection?.isConnected() ?? false;

  Future<void> disconnect() async {
    await _connection?.disconnect();
    _connection = null;
    _updateListeners();
  }

  Future<void> _retryConnection() async {
    if (_connection != null) {
      final prevConnectionStatus = _connection?.isConnected() ?? false;

      await _connection?.testConnections();
      await _connection?.connect();

      if (!(_connection?.isConnected() ?? false)) {
        _noConnectionReason = connectionToServerFailed;
      }

      if (prevConnectionStatus != _connection?.isConnected()) {
        _updateListeners();
      }
    }

    Future.delayed(const Duration(milliseconds: connectionRetryMs), () {
      _retryConnection();
    });
  }

  void _updateListeners() {
    var i = 0;
    while (i < listeners.length) {
      if (!listeners[i].item2()) {
        listeners.removeAt(i);
        continue;
      }
      i += 1;
    }

    for (final t in listeners) {
      t.item1();
    }
  }

  Future<void> rehashServerFile() async {
    await _serverHashFileLock.getLock();
    try {
      _connection!.getFileInterface().writeFileRelative(hashFile, Uint8List(0), true);
    }
    finally {
      _serverHashFileLock.releaseLock();
    }
  }

  Future<bool> refreshExistingFiles() async {
    _existingFiles = {};
    if (!isConnected()) {
      return false;
    }

    var file =
        await _connection!.getFileInterface().getFileRelative(hashFile);
    if (file == null) {
      await rehashServerFile();
      file = await _connection!.getFileInterface().getFileRelative(hashFile);
      if (file == null) {
        return false;
      }
    }

    final tExistingFiles = <int>{};

    file.listen((Uint8List data) {
      // Create a ByteData view of the Uint8List
      ByteData byteData = ByteData.sublistView(data);

      for (int i = 0; i < byteData.lengthInBytes; i += 8) {
        int value = byteData.getInt64(i, Endian.little);
        tExistingFiles.add(value);
      }
    });

    _existingFiles = tExistingFiles;
    return true;
  }

  Future<bool> addFileToHashes(List<String> paths) async {
    if (!isConnected()) {
      return false;
    }
    final bytes = ByteData(8 * paths.length);
    paths.asMap().forEach((i, path) {
      bytes.setInt64(i * 8, path.hashCode, Endian.little);
    });
    return await _connection!
        .getFileInterface()
        .appendFileRelative(hashFile, bytes.buffer.asUint8List());
  }

  Future<bool> sendImageToServer(Uint8List file, String path) async {
    if (!isConnected()) return false;

    print("Writing $path");

    await _connection!.getFileInterface().createAllDirsRelative(removePreSlash(File(path).parent.path));

    final writeResult =
        await _connection!.getFileInterface().writeFileRelative(removePreSlash(path), file, true);
    if (!writeResult) return false;
    final hashResult = await addFileToHashes([path]);
    if (!hashResult) {
      print("Failed to add '$path' to hash when write succeeded");
      return false;
    }
    return true;
  }

  Future<void> update() async {
    _connection?.disconnect();
    _connection = null;
    _existingFiles = {};

    if (!settingsStore.validData()) {
      _noConnectionReason = setUpConnectionInSettings;
      _updateListeners();
      return;
    }

    _updateListeners();

    final NasConnectionInterface interface;
    try {
      interface = getNasInterface(
          settingsStore.protocol(),
          settingsStore.localIp(),
          settingsStore.publicIp(),
          settingsStore.serverFolder(),
          settingsStore.username(),
          settingsStore.password());
    } on SettingsException catch (e) {
      print("Failed to set up connection (other) - $e");
      _noConnectionReason = badConnectionSettings;
      return;
    } on Exception catch (e) {
      print("Failed to set up connection (other) - $e");
      _noConnectionReason = badConnectionSettings;
      return;
    }

    _connection = interface;
    await _connection!.connect();

    if (!_connection!.isConnected()) {
      _noConnectionReason = connectionToServerFailed;
    } else {
      _noConnectionReason = "";
    }

    final fileRefreshSuccess = await refreshExistingFiles();
    if (!fileRefreshSuccess) {
      print("File refresh failed");
    }

    _updateListeners();
  }
}
