import 'package:flutter/material.dart';

FloatingActionButton? refreshButton(bool reloading, Function() onClick) {
  if (reloading) {
    return FloatingActionButton(
      onPressed: () {},
      tooltip: 'Refreshing...',
      backgroundColor: Colors.grey,
      child: const Icon(Icons.hourglass_top),
    );
  } else {
    return FloatingActionButton(
      onPressed: onClick,
      tooltip: 'Refresh',
      child: const Icon(Icons.refresh),
    );
  }
}
