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
      print("FNE: $e");
      print(st);
      return null;
    });
  } on Exception catch(e){
    print("FNE: $e");
    print(StackTrace.current);
    return null;
  }
}
