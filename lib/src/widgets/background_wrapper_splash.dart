import 'package:flutter/material.dart';

class BackgroundWrapperSplash extends StatelessWidget {
  final Widget child;

  const BackgroundWrapperSplash({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/splash_screen.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}