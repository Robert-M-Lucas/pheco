import 'package:flutter/material.dart';
import 'package:pheco/backend/actions/action_interface.dart';
import 'package:pheco/main.dart';

class RescanMediaStoreAction implements ActionInterface {
  const RescanMediaStoreAction();

  @override
  Icon getIcon() => const Icon(Icons.image_search);

  @override
  String getName() => "Rescan MediaStore";

  @override
  String getSubtitle() =>
      "Rescans the device for new images Android may not have found yet.";

  @override
  Future<void> run(Function(String) printer) async {
    printer("Note: This task has no progress indication -");
    printer("this can take around a minute");
    await platformChannel.invokeMethod('rescanMedia');
  }

  @override
  bool requireServerConnection() => false;

  @override
  bool requireValidSettings() => false;
}
