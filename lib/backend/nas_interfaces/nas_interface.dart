import 'package:pheco/backend/nas_interfaces/sftp_client.dart';
import 'package:pheco/backend/utils.dart';

abstract class NasInterface {
  Future<String?> testConnection();

  Future<void> connect();

  Future<void> disconnect();

  bool isConnected();

  bool isConnecting();
}

const List<String> protocolOptions = ['SFTP'];

const int connectionTimeoutMs = 5000;

ValidIp ipStringToPort(String ipString) {
  final split = ipString.split(':');
  if (split.length != 2) {
    throw SettingsException("[0] IPs must be formatted 123.456.789.123:4567");
  }
  final justIp = split[0];
  final justPort = split[1];

  final port = int.tryParse(justPort);
  if (port == null) {
    throw SettingsException("[1] IPs must be formatted 123.456.789.123:4567");
  }

  if (port < 0 || port > 65535) {
    throw SettingsException("Port must be 0-65535");
  }

  final ipSplit = justIp.split(".");
  if (ipSplit.length != 4) {
    throw SettingsException("[2] IPs must be formatted 123.456.789.123:4567");
  }

  ipSplit.map((e) {
    final ipPart = int.tryParse(e);
    if (ipPart == null) {
      throw SettingsException("[3] IPs must be formatted 123.456.789.123:4567");
    }
    if (ipPart < 0 || ipPart > 255) {
      throw SettingsException(
          "IP parts (e.g. xxx.123.123.123:1234) must be 0-255");
    }
    return ipPart;
  });

  return ValidIp(justIp, port);
}

NasInterface getNasInterface(String nasType, String localIp, String publicIp,
    String serverFolder, String username, String password) {
  if (localIp.isEmpty) {
    throw SettingsException("Local IP must be set");
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
