import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pheco/backend/gallery/local_gallery.dart';
import 'package:pheco/backend/nas/nas_client.dart';
import 'package:pheco/backend/settings_store.dart';
import 'package:pheco/ui/pages/local_gallery_page.dart';
import 'package:pheco/ui/pages/welcome_page.dart';
import 'package:receive_intent/receive_intent.dart';

const platformChannel = MethodChannel('com.example.pheco/channel');

late final PackageInfo packageInfo;

late final SettingsStore settingsStore;

late final NasClient nasClient;

late final LocalGallery localGallery;
// late final ServerGallery serverGallery;

AndroidOptions _getAndroidOptions() {
  return const AndroidOptions(encryptedSharedPreferences: true);
}

final secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());

void main() async {
  print("Init");

  WidgetsFlutterBinding.ensureInitialized();

  packageInfo = await PackageInfo.fromPlatform();

  settingsStore = SettingsStore();

  localGallery = LocalGallery();
  // serverGallery = ServerGallery();
  nasClient = NasClient();

  settingsStore.addUpdateListener(localGallery.update);
  settingsStore.addUpdateListener(nasClient.update);
  // nasClient.addUpdateListener(serverGallery.update);

  await settingsStore.initialise();

  nasClient.update();

  List<Permission> permissions = [
    Permission.storage,
    Permission.manageExternalStorage
  ];
  await permissions.request();

  final bool showWelcomePage = shouldShowWelcomePage();

  if (!showWelcomePage) {
    print("Skipping welcome page");
  }

  runApp(MyApp(showWelcomePage: showWelcomePage));
}

const Widget mainPage = LocalGalleryPage();

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.showWelcomePage});

  final bool showWelcomePage;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _intentStream;

  @override
  void initState() {
    super.initState();
    _checkInitialIntent();

    _intentStream = ReceiveIntent.receivedIntentStream.listen((intent) {
      print("xx");
      print("-$intent");
      print("Received live intent: ${intent?.data}");
      // Process intent (image/file path, etc.)
    });
  }

  void _checkInitialIntent() async {
    final intent = await ReceiveIntent.getInitialIntent();
    if (intent != null) {
      print("Received intent: ${intent.data}");
      // handle image or file URI here
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pheco',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: widget.showWelcomePage ? const WelcomePage() : mainPage,
    );
  }
}