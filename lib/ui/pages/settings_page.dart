import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pheco/ui/pages/about_page.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? _sp;

  bool _otherNetworks = true;
  bool _mobileData = false;
  String _protocol = 'SFTP';
  final List<String> _protocolOptions = ['SFTP', 'SMB'];
  String _selectedFrequency = 'Manual';
  final List<String> _frequencyOptions = [
    'Manual',
    'Hourly',
    'Daily',
    'Weekly',
    'Monthly'
  ];
  final TextEditingController _localIpFieldController = TextEditingController();
  final TextEditingController _publicIpFieldController =
      TextEditingController();
  final TextEditingController _usernameFieldController =
      TextEditingController();
  final TextEditingController _passwordFieldController =
      TextEditingController();
  bool _hidePassword = true;
  double _compressionStrength = 40;
  List<String> _folders = [];
  bool _folderMode = false; // False is exclude

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  Future<void> loadSettings() async {
    _sp = await SharedPreferences.getInstance();
    final keys = _sp!.getKeys();

    final prefsMap = <String, dynamic>{};
    for (String key in keys) {
      prefsMap[key] = _sp!.get(key);
    }

    print(prefsMap);

    final otherNetworks = await _getOrDefaultSet('otherNetworks', true);
    final mobileData = await _getOrDefaultSet('mobileData', false);
    final protocol = await _getOrDefaultSet('protocol', 'SFTP');
    final selectedFrequency = await _getOrDefaultSet('frequency', 'Manual');
    final localIpFieldControllerT = await _getOrDefaultSet('localIp', '');
    final publicIpFieldControllerT = await _getOrDefaultSet('publicIp', '');
    final usernameFieldControllerT = await _getOrDefaultSet('username', '');
    final passwordFieldControllerT = await _getOrDefaultSet('password', '');
    final compressionStrength =
        await _getOrDefaultSet('compressionStrength', 40.0);
    final folders = await _getOrDefaultSet('folders', <String>[]);
    final folderMode = await _getOrDefaultSet('folderMode', false);

    setState(() {
      _otherNetworks = otherNetworks;
      _mobileData = mobileData;
      _protocol = protocol;
      _selectedFrequency = selectedFrequency;
      _localIpFieldController.text = localIpFieldControllerT;
      _publicIpFieldController.text = publicIpFieldControllerT;
      _usernameFieldController.text = usernameFieldControllerT;
      _passwordFieldController.text = passwordFieldControllerT;
      _compressionStrength = compressionStrength;
      _folders = folders;
      _folderMode = folderMode;
    });
  }

  Future<void> pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _folders.add(selectedDirectory);
        _updateSetting("folders", _folders);
      });
    } else {
      print('Folder selection canceled.');
    }
  }

  Future<T> _getOrDefaultSet<T>(String key, T defaultValue) async {
    if (defaultValue is bool) {
      final val = _sp!.getBool(key);
      if (val == null) {
        await _sp!.setBool(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    } else if (defaultValue is int) {
      final val = _sp!.getInt(key);
      if (val == null) {
        await _sp!.setInt(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    } else if (defaultValue is double) {
      final val = _sp!.getDouble(key);
      if (val == null) {
        await _sp!.setDouble(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    } else if (defaultValue is String) {
      final val = _sp!.getString(key);
      if (val == null) {
        await _sp!.setString(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    } else if (defaultValue is List<String>) {
      final val = _sp!.getStringList(key);
      if (val == null) {
        await _sp!.setStringList(key, defaultValue);
        return defaultValue;
      } else {
        return val as T;
      }
    }
    print(defaultValue.runtimeType);
    return null as T;
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    _sp ??= await SharedPreferences.getInstance();
    if (value is bool) {
      await _sp!.setBool(key, value);
    } else if (value is String) {
      await _sp!.setString(key, value);
    } else if (value is double) {
      await _sp!.setDouble(key, value);
    } else if (value is List<String>) {
      await _sp!.setStringList(key, value);
    }
  }

  Widget settingsOptions(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            'Server Settings',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 100, 100, 100)),
          )),
        ),
        ListTile(
          title: const Text('Select Protocol'),
          subtitle: DropdownButton<String>(
            value: _protocol,
            onChanged: (String? newValue) {
              setState(() {
                _protocol = newValue!;
                _updateSetting("protocol", _protocol);
              });
            },
            items:
                _protocolOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Local IP with Port'),
          subtitle: TextField(
            controller: _localIpFieldController,
            onChanged: (newVal) {
              _updateSetting("localIp", newVal);
            },
            decoration: const InputDecoration(
              hintText: '192.168.1.230:22',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ListTile(
          title: const Text('(Optional) Public IP with Port'),
          subtitle: TextField(
            controller: _publicIpFieldController,
            onChanged: (newVal) {
              _updateSetting("publicIp", newVal);
            },
            decoration: const InputDecoration(
              hintText: '109.224.200.75:22',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ListTile(
          title: const Text('Username'),
          subtitle: TextField(
            controller: _usernameFieldController,
            onChanged: (newVal) {
              _updateSetting("username", newVal);
            },
            decoration: const InputDecoration(
              hintText: 'john_smith',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ListTile(
          title: const Text('Password'),
          subtitle: TextField(
            controller: _passwordFieldController,
            onChanged: (newVal) {
              _updateSetting("password", newVal);
            },
            obscureText: _hidePassword,
            decoration: InputDecoration(
              hintText: 'J0hnSm1thsPassw0rd!',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              ),
            ),
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            'Upload Settings',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 100, 100, 100)),
          )),
        ),
        ListTile(
          title: const Text('Select Upload Frequency'),
          subtitle: DropdownButton<String>(
            value: _selectedFrequency,
            onChanged: (String? newValue) {
              setState(() {
                _selectedFrequency = newValue!;
                _updateSetting("frequency", _selectedFrequency);
              });
            },
            items:
                _frequencyOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        SwitchListTile(
          title: const Text('Upload Over Other Networks'),
          subtitle:
              const Text('Images will be uploaded through other WiFi networks'),
          value: _otherNetworks,
          onChanged: (bool value) {
            setState(() {
              _otherNetworks = value;
              _updateSetting("otherNetworks", _otherNetworks);
            });
          },
        ),
        SwitchListTile(
          title: const Text('Upload Over Mobile Data'),
          subtitle: const Text('Images will be uploaded through mobile data'),
          value: _mobileData,
          onChanged: (bool value) {
            setState(() {
              _mobileData = value;
              _updateSetting("mobileData", _mobileData);
            });
          },
        ),
        SwitchListTile(
          title:
              Text('Using Folder ${_folderMode ? "Include" : "Exclude"} List'),
          subtitle: Text(
              'Tap to use folder ${_folderMode ? "exclude" : "include"} mode'),
          value: _folderMode,
          onChanged: (bool value) {
            setState(() {
              _folderMode = value;
              _updateSetting("folderMode", _folderMode);
            });
          },
        ),
        ListTile(
          title: Text('Add Folder to ${_folderMode ? "Include" : "Exclude"}'),
          trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                pickFolder();
              }),
        ),
        Column(
          children: _folders.asMap().entries.map((entry) {
            int index = entry.key;
            String folder = entry.value;
            return ListTile(
              title: Text(path.basename(folder)),
              subtitle: Text(folder),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _folders.removeAt(index);
                    _updateSetting("folders", _folders);
                  });
                },
              ),
            );
          }).toList(),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            'Image Settings',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 100, 100, 100)),
          )),
        ),
        ListTile(
          title: const Text('Compression Strength'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _compressionStrength,
                min: 5,
                max: 95,
                divisions: 18,
                label: '${_compressionStrength.round()}%',
                onChanged: (double value) {
                  setState(() {
                    _compressionStrength = value;
                    _updateSetting("compressionStrength", _compressionStrength);
                  });
                },
              ),
              Text('Selected: ${_compressionStrength.round()}%'),
            ],
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            'Other',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 100, 100, 100)),
          )),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          subtitle: const Text('App version and details'),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutPage()));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: settingsOptions(context),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     print("Refresh Button");
      //     const platform = MethodChannel('com.example.pheco/channel');
      //     await platform.invokeMethod('rescanMedia');
      //     print("Refresh Complete");
      //   },
      //   tooltip: 'Ransack',
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}
