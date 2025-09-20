import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackgroundWrapperLight extends StatelessWidget {
  final Widget child;

  const BackgroundWrapperLight({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which background image to use based on platform
    String backgroundImage;
    if (kIsWeb) {
      // Check current route to use appropriate web background
      final location = GoRouterState.of(context).uri.toString();
      if (location == '/supplier-login' || location == '/consumer-login') {
        backgroundImage = 'assets/images/web_app_login_screen.png';
      } else {
        backgroundImage = 'assets/images/web_app_background.png';
      }
    } else {
      backgroundImage = 'assets/images/login_screen.png';
    }

    return Stack(
      children: [
        // Background image layer
        Positioned.fill(
          child: Image.asset(
            backgroundImage,
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