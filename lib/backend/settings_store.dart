import 'dart:io';

import 'package:pheco/backend/nas_interfaces/nas_client.dart';
import 'package:pheco/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> protocolOptions = ['SFTP', 'SMB'];

const List<String> frequencyOptions = [
  'Manual',
  'Hourly',
  'Daily',
  'Weekly',
  'Monthly'
];

class SettingsStore {
  final List<Function()> listeners = [];

  bool _initialised = false;

  late SharedPreferences _sp;

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
  late bool _folderMode;
  bool folderMode() => _folderMode;
  late List<String> _folders;
  List<String> folders() => new List<String>.from(_folders);


  Future<void> initialise() async {
    _validData = _sp.getBool("validData") ?? false;

    await Future.wait([
      _sp.setBool("validData", true),
      _sp.setBool("otherNetworks", otherNetworks),
      _sp.setBool("mobileData", mobileData),
      _sp.setString("protocol", protocol),
      _sp.setString("frequency", frequency),
      _sp.setString("localIp", localIp),
      _sp.setString("publicIp", publicIp),
      _sp.setString("serverFolder", serverFolder),
      _sp.setString("username", username),
      secureStorage.write(key: 'password', value: password),
      _sp.setInt("compressionQuality", compressionQuality),
      _sp.setBool("folderMode", folderMode),
      _sp.setStringList("folders", folders),
    ]);

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
    if (protocolOptions.contains(protocol)) {
      return "Invalid protocol";
    }
    if (frequencyOptions.contains(frequency)) {
      return "Invalid frequency";
    }

    final nasResponse = await getNasInterfaceConfig(localIp, publicIp, serverFolder, username, password).testConnection();
    if (nasResponse == null) {
      return nasResponse;
    }
    
    if (compressionQuality < 5 || compressionQuality > 95) {
      return "Invalid compression quality";
    }

    for (final f in folders) {
      if ( await Directory(f).exists()) {
        return "Folder '${Directory(f).path}' doesn't exist";
      }
    }

    await Future.wait([
      _sp.setBool("otherNetworks", otherNetworks),
      _sp.setBool("mobileData", mobileData),
      _sp.setString("protocol", protocol),
      _sp.setString("frequency", frequency),
      _sp.setString("localIp", localIp),
      _sp.setString("publicIp", publicIp),
      _sp.setString("serverFolder", serverFolder),
      _sp.setString("username", username),
      secureStorage.write(key: 'password', value: password),
      _sp.setInt("compressionQuality", compressionQuality),
      _sp.setBool("folderMode", folderMode),
      _sp.setStringList("folders", folders),
      _sp.setBool("validData", true),
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
    return null;
  }

  Future<T> _getOrDefaultSet<T>(String key, T defaultValue) async {
    if (defaultValue is bool) {
      final val = _sp.getBool(key);
      if (val == null) {
        await _sp.setBool(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    } else if (defaultValue is int) {
      final val = _sp.getInt(key);
      if (val == null) {
        await _sp.setInt(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    } else if (defaultValue is double) {
      final val = _sp.getDouble(key);
      if (val == null) {
        await _sp.setDouble(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    } else if (defaultValue is String) {
      final val = _sp.getString(key);
      if (val == null) {
        await _sp.setString(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    } else if (defaultValue is List<String>) {
      final val = _sp.getStringList(key);
      if (val == null) {
        await _sp.setStringList(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    }
    print(defaultValue.runtimeType);
    return null as T;
  }
  
  void addUpdateListener(Function() permanentListener) {
    listeners.add(permanentListener);
  }

  void _updateListeners() {
    for (final l in listeners) {
      l();
    }
  }

  NasClient getNasInterface() {
    // TODO: implement getNasInterface
    throw UnimplementedError();
  }
}

NasClient getNasInterfaceConfig(String localIp, String publicIp, String serverFolder, String username, String password) {
  // TODO
  throw UnimplementedError();
}
