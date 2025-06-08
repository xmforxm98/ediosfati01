import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MobileWebWrapper extends StatelessWidget {
  final Widget child;

  const MobileWebWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // If not on web platform, return child as is
    if (!kIsWeb) {
      return child;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 440,
          height: 956,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              0,
            ), // Mobile devices don't have rounded corners typically
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
