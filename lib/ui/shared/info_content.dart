import 'package:flutter/material.dart';
import 'package:pheco/main.dart';

const int infoVersion = 7;

List<Widget> infoContent(BuildContext context) {
  return [
    Text(
      'What\'s New - v${packageInfo.version}/${packageInfo.buildNumber}',
      style: Theme.of(context).textTheme.headlineMedium,
    ),
    const Text(overviewText),
    const Divider(),
    Text(
      'Overview',
      style: Theme.of(context).textTheme.headlineMedium,
    ),
    const Text(overviewText),
    const Padding(padding: EdgeInsets.all(7.0)),
    Text(
      'Using Original Images',
      style: Theme.of(context).textTheme.headlineMedium,
    ),
    const Text(originalsText),
    const Padding(padding: EdgeInsets.all(7.0)),
    Text(
      'Server Connection',
      style: Theme.of(context).textTheme.headlineMedium,
    ),
    const Text(serverConnectionText),
    const Padding(padding: EdgeInsets.all(7.0)),
    Text(
      'Using Your Router for Storage',
      style: Theme.of(context).textTheme.headlineSmall,
    ),
    const Text(routerStorageText),
  ];
}

const String whatsNewText = "Nothing's new.";

const String overviewText = "Pheco compresses the images on your device and "
    "uploads the originals to a server, saving storage space. The original "
    "images are always available to you.";

const String originalsText = "You can share a compressed "
    "image with Pheco, which will show you sharing options for the full "
    "quality image, you can select an image from the in-app gallery and share "
    "the full quality version from there, or you can always restore all the "
    "full quality files to your phone. You must have the 'public IP' setting"
    "configured to be able to access the originals from outside your WiFi "
    "network";

const String serverConnectionText = "Pheco requires a storage server to "
    "connect to. The easiest way to set this up is to use your router, as "
    "detailed below. If you're router doesn't support this, you'll need to set"
    "up a NAS. Setting up the 'private IP' allows you to connect to the "
    "server when connected to your WiFi network whereas 'public IP' allows "
    "you to connect any time you have internet.";

const String routerStorageText = "Each router has a different interface for "
    "setting this up so reading the manual or searching online may be useful. "
    "The general steps are as follows:\n"
    " 1. Plug a USB storage device into the USB port in the back of the "
    "router\n"
    " 2. If need be, go into the router settings (usually by going to 192.168.1.1 or "
    "similar in a browser - this can be found on the label on the router) and "
    "enable the storage. You may also find the 'port', username, "
    "password, and protocol information for the storage there.\n"
    "3. Enter the IP:port (the IP is the same as the one for the router "
    "settings e.g. 192.168.1.1:1234) as the local address, "
    "username and password, as well as selecting the correct protocol in the "
    "settings. If you're unsure about any of these, looking online may help.\n"
    "\nNote: DO NOT DO THE BELOW STEP IF THERE IS NO PASSWORD PROTECTION ON THE "
    "STORAGE, IT WILL ALLOW ANYONE TO VIEW AND MODIFY YOUR DATA.\n\n"
    "4. [Optional] To connect to the server when outside your WiFi, you need "
    "to set up the 'public IP' in settings. You can find you're WiFi's public "
    "IP by searching 'what is my public IP' on any device connected to your "
    "WiFi. In your router settings, you need to connect the port coming in to "
    "the port and private IP where the storage device is in the 'port "
    "forwarding' menu. For example, if the private IP is 192.168.1.1 and the "
    "port is 1234, you should forward port 1234 to IP 192.168.1.1 and port "
    "1234 enabling UDP and TCP. You can then set the public IP as [public IP "
    "you found earlier]:1234 (e.g. 109.224.225.8:1234).";
