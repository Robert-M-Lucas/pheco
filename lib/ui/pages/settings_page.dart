import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pheco/backend/settings_store.dart';
import 'package:pheco/main.dart';
import 'package:pheco/ui/pages/about_page.dart';
import 'package:path/path.dart' as path;
import 'package:pheco/backend/utils.dart';

import '../../backend/nas_interfaces/nas_client.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _verified = false;
  bool _saving = false;
  bool _otherNetworks = true;
  bool _mobileData = false;
  String _protocol = protocolOptions[0];
  String _selectedFrequency = frequencyOptions[0];
  final TextEditingController _localIpFieldController = TextEditingController();

  final TextEditingController _publicIpFieldController =
      TextEditingController();
  final TextEditingController _serverFolderController = TextEditingController();
  final TextEditingController _usernameFieldController =
      TextEditingController();
  final TextEditingController _passwordFieldController =
      TextEditingController();
  bool _hidePassword = true;
  double _compressionQuality = 40;
  List<String> _folders = [];
  bool _folderMode = true; // False is exclude

  bool _popOnSave = false;
  final WidgetStateProperty<Icon?> _thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>((states) {
    if (states.contains(WidgetState.selected)) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.close);
  });

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  void loadSettings() {
    _verified = settingsStore.validData();

    if (!settingsStore.validData()) {
      return;
    }

    setState(() {
      _otherNetworks = settingsStore.otherNetworks();
      _mobileData = settingsStore.mobileData();
      _protocol = settingsStore.protocol();
      _selectedFrequency = settingsStore.frequency();
      _localIpFieldController.text = settingsStore.localIp();
      _publicIpFieldController.text = settingsStore.publicIp();
      _serverFolderController.text = settingsStore.serverFolder();
      _usernameFieldController.text = settingsStore.username();
      _passwordFieldController.text = settingsStore.password();
      _compressionQuality = settingsStore.compressionQuality().toDouble();
      _folders = settingsStore.folders();
      _folderMode = settingsStore.folderMode();
    });
  }

  Future<void> _pickFolder(BuildContext context) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _folders.add(selectedDirectory);
        _verified = false;
      });
    } else {
      print('Folder selection canceled.');
    }
  }

  Future<void> _verifySettings(BuildContext context) async {
    final String? result;
    try {
      result = await settingsStore.setValues(
          _otherNetworks,
          _mobileData,
          _protocol,
          _selectedFrequency,
          _localIpFieldController.text,
          _publicIpFieldController.text,
          _serverFolderController.text,
          _usernameFieldController.text,
          _passwordFieldController.text,
          _compressionQuality.toInt(),
          _folderMode,
          _folders);
    } on SettingsChangeException catch (p) {
      if (!mounted) {
        return;
      }
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Settings verification failed'),
            content: Text(
              p.cause,
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      );
      _popOnSave = false;
      return;
    }

    setState(() {
      _verified = true;
    });

    if (!mounted) {
      return;
    }

    if (result != null) {
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Settings Saved'),
            content: Text(
              result!,
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      );
    }

    if (_popOnSave) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _verifySettingsWrapper(BuildContext context) async {
    setState(() {
      _saving = true;
    });
    await _verifySettings(context);
    setState(() {
      _saving = false;
    });
  }

  Widget _settingsOptions(BuildContext context) {
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
                _verified = false;
              });
            },
            items:
                protocolOptions.map<DropdownMenuItem<String>>((String value) {
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
            onChanged: (_) {
              setState(() {
                _verified = false;
              });
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
            onChanged: (_) {
              setState(() {
                _verified = false;
              });
            },
            decoration: const InputDecoration(
              hintText: '109.224.200.75:22',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ListTile(
          title: const Text('Server Folder for Image Storage'),
          subtitle: TextField(
            controller: _serverFolderController,
            onChanged: (_) {
              setState(() {
                _verified = false;
              });
            },
            decoration: const InputDecoration(
              hintText: '/pheco/john',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ListTile(
          title: const Text('Username'),
          subtitle: TextField(
            controller: _usernameFieldController,
            onChanged: (_) {
              setState(() {
                _verified = false;
              });
            },
            decoration: const InputDecoration(
              hintText: 'john_smith',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ListTile(
          title: const Text('Password (optional)'),
          subtitle: TextField(
            controller: _passwordFieldController,
            onChanged: (_) {
              setState(() {
                _verified = false;
              });
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
                _verified = false;
              });
            },
            items:
                frequencyOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        SwitchListTile(
          title: const Text('Upload Over Other Networks'),
          thumbIcon: _thumbIcon,
          subtitle:
              const Text('Images will be uploaded through other WiFi networks'),
          value: _otherNetworks,
          onChanged: (bool value) {
            setState(() {
              _otherNetworks = value;
              _verified = false;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Upload Over Mobile Data'),
          thumbIcon: _thumbIcon,
          subtitle: const Text('Images will be uploaded through mobile data'),
          value: _mobileData,
          onChanged: (bool value) {
            setState(() {
              _mobileData = value;
              _verified = false;
            });
          },
        ),
        SwitchListTile(
          title:
              Text('Using Folder ${_folderMode ? "Include" : "Exclude"} List'),
          thumbIcon: _thumbIcon,
          subtitle: Text(
              'Tap to use folder ${_folderMode ? "exclude" : "include"} mode'),
          value: _folderMode,
          onChanged: (bool value) {
            setState(() {
              _folderMode = value;
              _verified = false;
            });
          },
        ),
        ListTile(
          title: Text('Add Folder to ${_folderMode ? "Include" : "Exclude"}'),
          trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _pickFolder(context);
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
          title: const Text('Compression Quality'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _compressionQuality,
                min: 5,
                max: 95,
                divisions: 18,
                label: '${_compressionQuality.round()}%',
                onChanged: (double value) {
                  setState(() {
                    _compressionQuality = value;
                  });
                },
              ),
              Text('Selected: ${_compressionQuality.round()}%'),
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

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You need to verify and save your settings values',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Discard'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Go Back'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }
          if (_saving) {
            if (!_popOnSave) {
              _popOnSave = true;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Please wait, saving in progress - will leave on save."),
              ));
            }
          } else {
            final bool shouldPop =
                _verified ? true : (await _showBackDialog() ?? false);
            if (context.mounted && shouldPop) {
              Navigator.pop(context);
            }
          }
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title:
                  const Text("Settings", style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: _settingsOptions(context),
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
            floatingActionButton: floatingActionButton(context)));
  }

  FloatingActionButton? floatingActionButton(BuildContext context) {
    if (_verified) {
      return null;
    } else {
      if (_saving) {
        return FloatingActionButton(
          onPressed: () {},
          tooltip: 'Saving...',
          backgroundColor: Colors.grey,
          child: const Icon(Icons.hourglass_top),
        );
      } else {
        return FloatingActionButton(
          onPressed: () {
            _verifySettingsWrapper(context);
          },
          tooltip: 'Save',
          child: const Icon(Icons.save),
        );
      }
    }
  }
}
