import 'package:flutter/material.dart';
import 'package:pheco/backend/actions/actions/compress_and_upload.dart';
import 'package:pheco/backend/actions/actions/print_test.dart';
import 'package:pheco/backend/actions/actions/rescan_mediastore.dart';

const List<ActionInterface> allActions = [
  PrintTestAction(),
  CompressAndUploadAction(),
  RescanMediaStoreAction()
];

abstract interface class ActionInterface {
  Icon getIcon();

  String getName();

  String getSubtitle();

  bool requireValidSettings();
  bool requireServerConnection();

  Future<void> run(Function(String) printer);
}
