import 'package:dartssh2/dartssh2.dart';
import 'package:pheco/backend/nas_interfaces/nas_client.dart';

import '../utils.dart';

class PSftpClient implements NasClient {
  const PSftpClient(this.localIp, this.publicIp, this.serverFolder,
      this.username, this.password);

  final ValidIp localIp;
  final ValidIp? publicIp;
  final String serverFolder;
  final String username;
  final String password;

  Future<SSHClient> getLocalClient(ValidIp ip) async {
    return SSHClient(
      await SSHSocket.connect(ip.ip, ip.port),
      username: username,
      onPasswordRequest: () => password,
    );
  }

  @override
  Future<String?> testConnection() async {
    return null;
  }
}
