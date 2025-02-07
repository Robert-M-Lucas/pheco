import 'package:tuple/tuple.dart';

abstract class GalleryInterface {
  final List<Tuple2<Function(), bool Function()>> _dependencies = [];

  String noReturnReason(String? folder);

  void initialiseIfUninitialised();

  void registerUpdateCallback(Function() callback, bool Function() aliveChecker) {
    _dependencies.add(Tuple2(callback, aliveChecker));
  }

  void updateDependencies() {
    var i = 0;
    while (i < _dependencies.length) {
      if (!_dependencies[i].item2()) {
        _dependencies.removeAt(i);
        continue;
      }
      i += 1;
    }

    for (final t in _dependencies) {
      t.item1();
    }
  }

  void update();

  List<String>? getFolderList();

  /// Returns files in the specified folder or all files if `folder` is null
  List<String>? getFilesInFolder(String? folder);
}
