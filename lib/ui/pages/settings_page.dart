import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:pheco/ui/pages/about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _otherNetworks = true;
  bool _mobileData = false;
  String _selectedProtocol = 'SFTP';
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
  final TextEditingController _publicIpFieldController = TextEditingController();
  final TextEditingController _usernameFieldController = TextEditingController();
  final TextEditingController _passwordFieldController = TextEditingController();
  bool _hidePassword = true;
  double _compressionStrength = 95;

  Future<void> serverConnect() async {
    print("Connecting to server");
    final client = SSHClient(
      await SSHSocket.connect('192.168.1.230', 22),
      username: 'robert',
      onPasswordRequest: () => 'TheTestPassword!',
    );

    print("Connected");

    final sftp = await client.sftp();
    final items = await sftp.listdir('/home/robert');
    for (final item in items) {
      print(item.longname);
    }

    print("Writing file");
    final file = await sftp.open('sftp_test.txt',
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
    await file.writeBytes(utf8.encode('hello there!'));
    await file.close();
    print("File written");
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
            value: _selectedProtocol,
            onChanged: (String? newValue) {
              setState(() {
                _selectedProtocol = newValue!;
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
            });
          },
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
        title:
            const Text("Settings Page", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: settingsOptions(context),
    );
  }
}
