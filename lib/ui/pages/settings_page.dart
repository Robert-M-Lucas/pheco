import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
    final file = await sftp.open('sftp_test.txt', mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
    await file.writeBytes(utf8.encode('hello there!'));
    await file.close();
    print("File written");
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Settings will go here',
            ),
            Text(
              'Sit tight',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Button Server");
          serverConnect();
        },
        tooltip: 'Server Connect',
        child: const Icon(Icons.storage),
      ),
    );
  }
}
