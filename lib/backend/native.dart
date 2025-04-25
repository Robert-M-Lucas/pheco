import 'package:pheco/main.dart';

Future<void> rescanMedia({String? path}) async {
  await platformChannel.invokeMethod('rescanMedia', {'path': path});
}