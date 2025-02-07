import 'package:pheco/backend/nas_interfaces/nas_client.dart';

class SettingsStore {
  final List<Function ()> listeners = [];
  
  void addUpdateListener(Function() permanentListener) {
    listeners.add(permanentListener);
  }

  void _updateListeners() {
    for (final l in listeners) {
      l();
    }
  }

  NasClient getNasInterface() {
    // TODO: implement getNasInterface
    throw UnimplementedError();
  }
}
