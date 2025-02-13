import 'package:dartssh2/dartssh2.dart';
import 'package:pheco/backend/nas_interfaces/nas_interface.dart';
import 'package:pheco/backend/utils.dart';

class PSftpClient implements NasInterface {
  PSftpClient(this._localIp, this._publicIp, this._serverFolder, this._username,
      this._password);

  final ValidIp _localIp;
  final ValidIp? _publicIp;
  final String _serverFolder;
  final String _username;
  final String _password;

  SftpClient? _localClient;
  SftpClient? _publicClient;
  bool _isConnecting = false;

  Future<SSHClient> _getClient(ValidIp ip) async {
    return SSHClient(
      await SSHSocket.connect(ip.ip, ip.port,
          timeout: const Duration(milliseconds: connectionTimeoutMs)),
      username: _username,
      onPasswordRequest: () => _password,
    );
  }

  @override
  Future<String?> testConnectionSettings() async {
    print("Testing local connection - $_localIp");

    Future<SSHClient?> getLocalClient() async {
      try {
        return await _getClient(_localIp);
      } on Exception catch (e) {
        print(e);
      }
      return null;
    }

    Future<SSHClient?> getPublicClient() async {
      if (_publicIp == null) {
        return null;
      }
      try {
        return await _getClient(_publicIp);
      } on Exception catch (e) {
        print(e);
      }
      return null;
    }

    print("Testing local/public connection");
    final clients =
        await Future.wait<SSHClient?>([getLocalClient(), getPublicClient()]);

    SSHClient? localClient = clients[0];
    SSHClient? publicClient = clients[1];

    print("Local: ${localClient != null} | Public: ${publicClient != null}");

    if (localClient == null && _publicIp == null) {
      throw SettingsException(
          "Failed to connect to server through public or private IP");
    }

    print("Testing authentication / SFTP");

    final SftpClient testClient;
    try {
      testClient = await (localClient ?? publicClient!).sftp();
      print(await testClient.listdir("/"));
    } catch (e) {
      print(e);
      throw SettingsException(
          "Failed to authenticate with SFTP server. Check username and password.");
    }

    print("Done");

    if (localClient == null) {
      return "Failed to connect through local IP but succeeded through public IP.";
    }
    if (publicClient == null && _publicIp != null) {
      return "Failed to connect through public IP but succeeded through local IP.";
    }
    return null;
  }

  @override
  Future<void> disconnect() async {
    final localClient = _localClient;
    _localClient = null;
    final publicClient = _publicClient;
    _publicClient = null;

    localClient?.close();
    publicClient?.close();
  }

  @override
  Future<void> connect() async {
    if (_isConnecting) {
      return;
    }

    _isConnecting = true;
    print("Connecting clients");

    Future<SftpClient?> getLocalClient() async {
      try {
        final sshClient = await _getClient(_localIp);
        return await sshClient.sftp();
      } on Exception catch (e) {
        print(e);
      }
      return null;
    }

    Future<SftpClient?> getPublicClient() async {
      if (_publicIp == null) {
        return null;
      }
      try {
        final sshClient = await _getClient(_publicIp);
        return await sshClient.sftp();
      } on Exception catch (e) {
        print(e);
      }
      return null;
    }

    final clients = await Future.wait<SftpClient?>(
        (_localClient == null ? [getLocalClient()] : <Future<SftpClient?>>[]) +
            (_publicClient == null ? [getPublicClient()] : []));

    SftpClient? localClient = _localClient ?? clients.removeAt(0);
    SftpClient? publicClient = _publicClient ?? clients.removeAt(0);

    _localClient = localClient;
    _publicClient = publicClient;
    print(
        "Connected clients -  Local: ${_localClient != null} | Public : ${_publicClient != null}");
    _isConnecting = false;
  }

  @override
  bool isConnected() {
    return _localClient != null || _publicClient != null;
  }

  @override
  Future<void> testConnections() async {
    Future<void> testLocalConnection() async {
      try {
        await _localClient?.listdir("/");
      } catch (e) {
        print(e);
        _localClient = null;
      }
    }

    Future<void> testPublicConnection() async {
      try {
        await _publicClient?.listdir("/");
      } catch (e) {
        print(e);
        _publicClient = null;
      }
    }

    print("Testing connections");

    await Future.wait([testLocalConnection(), testPublicConnection()]);

    print(
        "Connected clients -  Local: ${_localClient != null} | Public : ${_publicClient != null}");
  }
}
