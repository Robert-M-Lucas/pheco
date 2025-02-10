import 'package:pheco/backend/nas_interfaces/sftp_client.dart';

import '../utils.dart';

abstract class NasClient {
  Future<String?> testConnection();
}

const List<String> protocolOptions = ['SFTP', 'SMB'];

ValidIp ipStringToPort(String ipString) {
  final split = ipString.split(':');
  if (split.length != 2) {
    throw SettingsChangeException("[0] IPs must be formatted 123.456.789.123:4567");
  }
  final justIp = split[0];
  final justPort = split[1];

  final port = int.tryParse(justPort);
  if (port == null) {
    throw SettingsChangeException("[1] IPs must be formatted 123.456.789.123:4567");
  }

  if (port < 0 || port > 65535) {
    throw SettingsChangeException("Port must be 0-65535");
  }

  final ipSplit = justIp.split(".");
  if (ipSplit.length != 4) {
    throw SettingsChangeException("[2] IPs must be formatted 123.456.789.123:4567");
  }

  ipSplit.map((e) {
    final ipPart = int.tryParse(e);
    if (ipPart == null) {
      throw SettingsChangeException(
          "[3] IPs must be formatted 123.456.789.123:4567");
    }
    if (ipPart < 0 || ipPart > 255) {
      throw SettingsChangeException(
          "IP parts (e.g. xxx.123.123.123:1234) must be 0-255");
    }
    return ipPart;
  });

  return ValidIp(justIp, port);
}

NasClient getNasInterface(String nasType, String localIp, String publicIp,
    String serverFolder, String username, String password) {

  if (localIp.isEmpty) {
    throw SettingsChangeException("Local IP must be set");
  }

  final publicIpV = publicIp.isEmpty ? null : ipStringToPort(publicIp);
  final localIpV = ipStringToPort(localIp);

  print("Getting nas client");

  switch (nasType) {
    case 'SFTP':
      return PSftpClient(localIpV, publicIpV, serverFolder, username, password);
    default:
      throw UnimplementedError();
  }
}
