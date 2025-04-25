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