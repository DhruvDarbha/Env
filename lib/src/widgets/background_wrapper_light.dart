import 'package:flutter/material.dart';

class BackgroundWrapperLight extends StatelessWidget {
  final Widget child;

  const BackgroundWrapperLight({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login_screen.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
        ),
        child: child,
      ),
    );
  }
}