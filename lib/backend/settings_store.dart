import 'dart:io';

import 'package:pheco/backend/utils.dart';
import 'package:pheco/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nas/nas_utils.dart';

const List<String> frequencyOptions = [
  'Manual',
  'Hourly',
  'Daily',
  'Weekly',
  'Monthly'
];

const String validDataKey = "validData";
const String otherNetworksKey = "otherNetworks";
const String mobileDataKey = "mobileData";
const String protocolKey = "protocol";
const String frequencyKey = "frequency";
const String localIpKey = "localIp";
const String publicIpKey = "publicIp";
const String serverFolderKey = "serverFolder";
const String usernameKey = "username";
const String passwordKey = "password";
const String compressionQualityKey = "compressionQuality";
const String folderModeKey = "folderMode";
const String foldersKey = "folders";
const String welcomeVersionKey = "welcomeVersion";

class SettingsStore {
  final List<Function()> listeners = [];

  late final SharedPreferences _sp;

  bool _validData = false;
  bool validData() => _validData;

  late bool _otherNetworks;
  bool otherNetworks() => _otherNetworks;
  late bool _mobileData;
  bool mobileData() => _mobileData;
  late String _protocol;
  String protocol() => _protocol;
  late String _frequency;
  String frequency() => _frequency;
  late String _localIp;
  String localIp() => _localIp;
  late String _publicIp;
  String publicIp() => _publicIp;
  late String _serverFolder;
  String serverFolder() => _serverFolder;
  late String _username;
  String username() => _username;
  late String _password;
  String password() => _password;
  late int _compressionQuality;
  int compressionQuality() => _compressionQuality;
  bool? _folderMode;
  bool folderMode() => _folderMode ?? false;
  List<String> _folders = [];
  List<String> folders() => List.unmodifiable(_folders);

  int? _welcomeVersion;

  Future<void> initialise() async {
    _sp = await SharedPreferences.getInstance();

    _validData = _sp.getBool(validDataKey) ?? false;

    if (_validData) {
      _otherNetworks = _sp.getBool(otherNetworksKey)!;
      _mobileData = _sp.getBool(mobileDataKey)!;
      _protocol = _sp.getString(protocolKey)!;
      _frequency = _sp.getString(frequencyKey)!;
      _localIp = _sp.getString(localIpKey)!;
      _publicIp = _sp.getString(publicIpKey)!;
      _serverFolder = _sp.getString(serverFolderKey)!;
      _username = _sp.getString(usernameKey)!;
      _password = (await secureStorage.read(key: passwordKey))!;
      _compressionQuality = _sp.getInt(compressionQualityKey)!;
      _folderMode = _sp.getBool(folderModeKey)!;
      _folders = _sp.getStringList(foldersKey)!;
    }

    _welcomeVersion = _sp.getInt(welcomeVersionKey);

    _updateListeners();
  }

  Future<String?> setValues(
      bool otherNetworks,
      bool mobileData,
      String protocol,
      String frequency,
      String localIp,
      String publicIp,
      String serverFolder,
      String username,
      String password,
      int compressionQuality,
      bool folderMode,
      List<String> folders) async {
    if (!protocolOptions.contains(protocol)) {
      throw SettingsException("Invalid protocol");
    }
    if (!frequencyOptions.contains(frequency)) {
      throw SettingsException("Invalid frequency");
    }

    if (compressionQuality < 5 || compressionQuality > 95) {
      throw SettingsException("Invalid compression quality");
    }

    for (final f in folders) {
      if (await Directory(f).exists()) {
        throw SettingsException("Folder '${Directory(f).path}' doesn't exist");
      }
    }

    // Required to not interfere
    nasClient.disconnect();
    await Future.delayed(const Duration(milliseconds: connectionTimeoutMs));

    final String? nasResponse;
    try {
      nasResponse = await getNasInterface(
              protocol, localIp, publicIp, serverFolder, username, password)
          .testConnectionSettings();
    } on Exception {
      // Ensure nasClient is restarted
      _updateListeners();
      rethrow;
    }

    await Future.wait([
      _sp.setBool(otherNetworksKey, otherNetworks),
      _sp.setBool(mobileDataKey, mobileData),
      _sp.setString(protocolKey, protocol),
      _sp.setString(frequencyKey, frequency),
      _sp.setString(localIpKey, localIp),
      _sp.setString(publicIpKey, publicIp),
      _sp.setString(serverFolderKey, serverFolder),
      _sp.setString(usernameKey, username),
      secureStorage.write(key: passwordKey, value: password),
      _sp.setInt(compressionQualityKey, compressionQuality),
      _sp.setBool(folderModeKey, folderMode),
      _sp.setStringList(foldersKey, folders),
      _sp.setBool(validDataKey, true),
    ]);

    _otherNetworks = otherNetworks;
    _mobileData = mobileData;
    _protocol = protocol;
    _frequency = frequency;
    _localIp = localIp;
    _publicIp = publicIp;
    _serverFolder = serverFolder;
    _username = username;
    _password = password;
    _compressionQuality = compressionQuality;
    _folderMode = folderMode;
    _folders = folders;

    _validData = true;

    _updateListeners();
    return nasResponse;
  }

  int? welcomeVersion() {
    return _welcomeVersion;
  }

  Future<void> setWelcomeVersion(int version) async {
    await _sp.setInt(welcomeVersionKey, version);
  }

  void addUpdateListener(Function() permanentListener) {
    listeners.add(permanentListener);
  }

  void _updateListeners() {
    for (final l in listeners) {
      l();
    }
  }
}
