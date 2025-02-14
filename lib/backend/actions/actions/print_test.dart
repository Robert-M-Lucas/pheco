import 'package:flutter/material.dart';
import 'package:pheco/backend/actions/action_interface.dart';

class PrintTestAction implements ActionInterface {
  const PrintTestAction();

  @override
  Icon getIcon() => const Icon(Icons.print);

  @override
  String getName() => "Print Test";

  @override
  String getSubtitle() => "Tests printing.";

  @override
  Future<void> run(Function(String) printer) async {
    printer("Test print");
    printer("Delaying...");
    await Future.delayed(const Duration(milliseconds: 1000));
    printer("Done delaying");
  }

  @override
  bool requireServerConnection() => false;

  @override
  bool requireValidSettings() => false;
}
