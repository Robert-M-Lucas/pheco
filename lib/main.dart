import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pheco/backend/gallery/local_gallery.dart';
import 'package:pheco/backend/gallery/server_gallery.dart';
import 'package:pheco/backend/nas/nas_client.dart';
import 'package:pheco/backend/settings_store.dart';
import 'package:pheco/ui/pages/local_gallery_page.dart';
import 'package:pheco/ui/pages/welcome_page.dart';

const platformChannel = MethodChannel('com.example.pheco/channel');

late SettingsStore settingsStore;

late NasClient nasClient;

late LocalGallery localGallery;
late ServerGallery serverGallery;

AndroidOptions _getAndroidOptions() {
  return const AndroidOptions(encryptedSharedPreferences: true);
}

final secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());

void main() async {
  print("Init");

  WidgetsFlutterBinding.ensureInitialized();

  settingsStore = SettingsStore();

  localGallery = LocalGallery();
  serverGallery = ServerGallery();
  nasClient = NasClient();

  settingsStore.addUpdateListener(localGallery.update);
  settingsStore.addUpdateListener(nasClient.update);
  nasClient.addUpdateListener(serverGallery.update);

  await settingsStore.initialise();

  nasClient.update();

  List<Permission> permissions = [
    Permission.storage,
  ];
  await permissions.request();

  final bool showWelcomePage = shouldShowWelcomePage();

  if (!showWelcomePage) {
    print("Skipping welcome page");
  }

  runApp(MyApp(showWelcomePage: showWelcomePage));
}

const Widget mainPage = LocalGalleryPage();

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showWelcomePage});

  final bool showWelcomePage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pheco',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: showWelcomePage ? const WelcomePage() : mainPage,
    );
  }
}
