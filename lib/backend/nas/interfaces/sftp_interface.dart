import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:pheco/backend/nas/nas_interface.dart';
import 'package:pheco/backend/utils.dart';

import '../nas_utils.dart';

class SftpInterface implements NasConnectionInterface, NasFileInterface {
  SftpInterface(this._localIp, this._publicIp, serverFolder, this._username,
      this._password) {
    if (!serverFolder.endsWith('/')) {
      serverFolder += '/';
    }
    _serverFolder = serverFolder;
  }

  final ValidIp _localIp;
  final ValidIp? _publicIp;
  late final String _serverFolder;
  final String _username;
  final String _password;

  SftpClient? _localClient;
  SftpClient? _publicClient;
  SftpClient? _getClient() => _localClient ?? _publicClient;
  bool _isConnecting = false;

  Future<SSHClient> _getSSHClient(ValidIp ip) async {
    return SSHClient(
      await SSHSocket.connect(ip.ip, ip.port,
          timeout: const Duration(milliseconds: connectionTimeoutMs)),
      username: _username,
      onPasswordRequest: () => _password,
    );
  }

  @override
  Future<String?> testConnectionSettings() async {
    print("Testing local/public connection");

    await connect();

    if (!isConnected()) {
      throw SettingsException(
          "Failed to connect to server through public or private IP");
    }

    print("Testing authentication / SFTP");

    final bool? initialised = await futureNullError(initialiseRootDir());
    if (initialised == null) {
      throw SettingsException(
          "Failed to authenticate with SFTP server. Check username and password.");
    }

    if (!initialised) {
      throw SettingsException(
          "Failed to initialise directory. Check the path.");
    }

    print("Done");

    if (_localClient == null) {
      return "Failed to connect through local IP but succeeded through public IP.";
    }
    if (_publicClient == null && _publicIp != null) {
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

    final prevConnected = isConnected();

    _isConnecting = true;
    print("Connecting clients");

    Future<SftpClient?> getLocalClient() async {
      final sshClient = await futureNullError(_getSSHClient(_localIp));
      if (sshClient == null) return null;
      return await futureNullError(sshClient.sftp());
    }

    Future<SftpClient?> getPublicClient() async {
      if (_publicIp == null) {
        return null;
      }
      final sshClient = await futureNullError(_getSSHClient(_publicIp));
      if (sshClient == null) return null;
      return await sshClient.sftp();
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

    if (isConnected() && !prevConnected) {
      await initialiseRootDir();
    }

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

  @override
  NasFileInterface getFileInterface() {
    return this;
  }

  @override
  Future<List<String>?> listFoldersInDirRelative(String dir) async {
    final clientN = _getClient();
    if (clientN == null) {
      return null;
    }
    final SftpClient client = clientN;

    final List<SftpName>? dirList =
        await futureNullError(client.listdir(_serverFolder + dir));
    if (dirList == null) return null;

    return dirList
        .where((e) => e.attr.isDirectory)
        .map((e) => e.filename)
        .toList();
  }

  @override
  Future<bool> dirExistsRelative(String dir) async {
    final client = _getClient();
    if (client == null) {
      return false;
    }
    return await client
        .readdir(Directory(dir).parent.path)
        .isEmpty
        .then((_) => true)
        .onError((_, __) => false);
  }

  @override
  Future<bool> createAllDirsAbsolute(String dir) async {
    print("Create all dirs: $dir");
    final client = _getClient();
    if (client == null) {
      return false;
    }

    if (await dirExistsRelative(dir)) {
      print("Dir exists");
      return true;
    }

    final split = dir.split('/').toList();
    split.removeAt(0);
    var currentDir = "";
    var finalResult = false;

    for (final part in split) {
      currentDir += "/$part";
      try {
        print("Creating $currentDir");
        finalResult = await client
            .mkdir(currentDir)
            .then((_) => true)
            .onError((_, __) => false);
        print(finalResult);
      } on Exception catch (e) {
        print(e);
      }
    }

    return await dirExistsRelative(dir);
  }

  @override
  Future<bool> initialiseRootDir() async {
    return await createAllDirsAbsolute(_serverFolder);
  }

  @override
  Future<Stream<Uint8List>?> getFileRelative(String path) async {
    final client = _getClient();
    if (client == null) {
      return null;
    }

    final SftpFile? file =
        await futureNullError(client.open(_serverFolder + path));
    return file?.read();
  }

  @override
  Future<bool> writeFileRelative(String path, Uint8List contents) async {
    final client = _getClient();
    if (client == null) {
      return false;
    }

    final file = await client.open(_serverFolder + path);
    try {
      await file.writeBytes(contents);
    } on Exception catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  @override
  Future<bool> appendFileRelative(String path, Uint8List contents) async {
    final client = _getClient();
    if (client == null) {
      return false;
    }

    final file = await client.open(_serverFolder + path);
    try {
      final size = (await file.stat()).size!;
      await file.writeBytes(contents, offset: size);
    } on Exception catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
