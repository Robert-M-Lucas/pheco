import 'package:pheco/backend/nas/nas_interface.dart';
import 'package:pheco/backend/utils.dart';
import 'package:pheco/main.dart';
import 'package:tuple/tuple.dart';

import 'nas_utils.dart';

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

  void disconnect() {
    _connection?.disconnect();
    _connection = null;
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

  Future<void> update() async {
    _connection?.disconnect();
    _connection = null;

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

    _updateListeners();
  }
}
