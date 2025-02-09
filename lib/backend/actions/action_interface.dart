import 'package:flutter/material.dart';
import 'package:pheco/backend/actions/actions/print_test.dart';
import 'package:pheco/backend/actions/actions/rescan_mediastore.dart';

const List<ActionInterface> allActions = [
  PrintTestAction(),
  RescanMediaStoreAction()
];

abstract class ActionInterface {
  Icon getIcon();

  String getName();

  String getSubtitle();

  Future<void> run(Function(String) printer);
}
