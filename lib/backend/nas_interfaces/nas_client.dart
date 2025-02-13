import 'package:pheco/backend/nas_interfaces/nas_interface.dart';
import 'package:pheco/backend/utils.dart';
import 'package:pheco/main.dart';
import 'package:tuple/tuple.dart';

const int connectionRetryMs = 5000;

class NasClient {
  NasClient() {
    Future.delayed(const Duration(milliseconds: connectionRetryMs), () {
      _retryConnection();
    });
  }

  String _noConnectionReason = "";
  String noConnectionReason() => _noConnectionReason;

  final List<Tuple2<Function(), bool Function()>> listeners = [];

  NasInterface? _connection;

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

  Future<void> _retryConnection() async {
    if (_connection != null &&
        !_connection!.isConnected() &&
        !_connection!.isConnecting()) {
      await _connection!.connect();
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
      _noConnectionReason = "Set up a connection in settings";
      _updateListeners();
      return;
    }

    _updateListeners();

    final NasInterface interface;
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
      _noConnectionReason = "Bad connection settings";
      return;
    } on Exception catch (e) {
      print("Failed to set up connection (other) - $e");
      _noConnectionReason = "Bad connection settings";
      return;
    }

    _connection = interface;
    await _connection!.connect();

    if (!_connection!.isConnected()) {
      _noConnectionReason = "Connection to server failed";
    } else {
      _noConnectionReason = "";
    }

    _updateListeners();
  }
}
