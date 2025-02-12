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

  Future<SSHClient> getClient(ValidIp ip) async {
    return SSHClient(
      await SSHSocket.connect(ip.ip, ip.port,
          timeout: const Duration(milliseconds: 2500)),
      username: username,
      onPasswordRequest: () => password,
    );
  }

  @override
  Future<String?> testConnection() async {
    print("Testing local connection - $localIp");

    SSHClient? localClient;
    try {
      localClient = await getClient(localIp);
    } catch (e) {
      print(e);
      localClient = null;
    }

    print("Testing public connection - $publicIp");
    SSHClient? publicClient;
    try {
      publicClient = publicIp != null ? await getClient(publicIp!) : null;
    } catch (e) {
      print(e);
      publicClient = null;
    }

    print("Local: ${localClient != null} | Public: ${publicClient != null}");

    if (localClient == null && publicIp == null) {
      throw SettingsChangeException(
          "Failed to connect to server through public or private IP");
    }

    print("Testing authentication / SFTP");

    final SftpClient testClient;
    try {
      testClient = await (localClient ?? publicClient!).sftp();
      print(await testClient.listdir("/"));
    } catch (e) {
      print(e);
      throw SettingsChangeException(
          "Failed to authenticate with SFTP server. Check username and password.");
    }

    print("Done");

    if (localClient == null) {
      return "Failed to connect through local IP but succeeded through public IP. Settings saved.";
    }
    if (publicClient == null && publicIp != null) {
      return "Failed to connect through public IP but succeeded through local IP. Settings saved.";
    }
    return null;
  }
}
