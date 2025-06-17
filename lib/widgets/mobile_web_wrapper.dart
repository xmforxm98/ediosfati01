import 'package:flutter/material.dart';

class MobileWebWrapper extends StatelessWidget {
  final Widget child;

  const MobileWebWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Return child directly without any container constraints
    return child;
  }
}
