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
    return await f.then((v) => v as T?).onError((_, __) => null);
  } on Exception {
    return null;
  }
}
