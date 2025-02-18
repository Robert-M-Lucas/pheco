import 'package:flutter/material.dart';
import 'package:pheco/ui/pages/local_gallery_page.dart';
import 'package:pheco/ui/pages/run_page.dart';
import 'package:pheco/ui/pages/server_gallery_page.dart';
import 'package:pheco/ui/shared/gallery_content.dart';

class MainBottomBar extends StatefulWidget {
  const MainBottomBar({super.key, required this.type, required this.enabled});

  final GalleryType? type;
  final bool enabled;

  @override
  State<MainBottomBar> createState() => _MainBottomBarState();
}

class _MainBottomBarState extends State<MainBottomBar> {
  void navigateToOther(GalleryType other) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          other == GalleryType.local
              ? const LocalGalleryPage()
              : const ServerGalleryPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: 0.0, end: 1.0);
        final opacityAnimation = animation.drive(tween);
        return FadeTransition(opacity: opacityAnimation, child: child);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: SizedBox.expand(
              child: IconButton(
                isSelected: widget.type == GalleryType.local,
                icon: const Icon(Icons.home, size: 30),
                onPressed: widget.enabled
                    ? () {
                        if (widget.type != GalleryType.local) {
                          navigateToOther(GalleryType.local);
                        }
                      }
                    : null,
              ),
            ),
          ),
          Expanded(
            child: SizedBox.expand(
              child: IconButton(
                isSelected: widget.type == GalleryType.serverOnly,
                icon: const Icon(Icons.storage, size: 30),
                onPressed: widget.enabled
                    ? () {
                        if (widget.type != GalleryType.serverOnly) {
                          navigateToOther(GalleryType.serverOnly);
                        }
                      }
                    : null,
              ),
            ),
          ),
          Expanded(
            child: SizedBox.expand(
              child: IconButton(
                isSelected: widget.type == null,
                icon: const Icon(Icons.play_arrow, size: 30),
                onPressed: widget.enabled
                    ? () {
                        Navigator.of(context).pushReplacement(PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const RunPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            final tween = Tween(begin: 0.0, end: 1.0);
                            final opacityAnimation = animation.drive(tween);
                            return FadeTransition(
                                opacity: opacityAnimation, child: child);
                          },
                        ));
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
