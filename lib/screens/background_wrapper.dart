// background_wrapper.dart
import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/gf.png"),
          fit: BoxFit.cover,
          opacity: 0.05, // Light watermark effect
        ),
      ),
      child: child,
    );
  }
}
