import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BackgroundWrapperSplash extends StatelessWidget {
  final Widget child;

  const BackgroundWrapperSplash({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which splash image to use based on platform
    String splashImage;
    if (kIsWeb) {
      splashImage = 'assets/images/web_app_splash.png';
    } else {
      splashImage = 'assets/images/splash_screen.png';
    }

    return Stack(
      children: [
        // Background image layer
        Positioned.fill(
          child: Image.asset(
            splashImage,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        // Content layer
        child,
      ],
    );
  }
}