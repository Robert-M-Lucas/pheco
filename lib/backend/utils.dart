class SettingsChangeException implements Exception {
  String cause;
  SettingsChangeException(this.cause);
}

class ValidIp {
  const ValidIp(this.ip, this.port);

  final String ip;
  final int port;
}
