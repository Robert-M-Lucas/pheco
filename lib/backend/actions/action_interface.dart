

import 'package:flutter/material.dart';
import 'package:pheco/backend/actions/actions/print_test.dart';

const List<ActionInterface> allActions = [
  PrintTestAction()
];

abstract class ActionInterface {
  Icon getIcon();

  String getName();

  String getSubtitle();

  Future<void> run(Function(String) printer);
}