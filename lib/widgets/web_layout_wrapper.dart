import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class WebLayoutWrapper extends StatelessWidget {
  final Widget child;
  final bool forceWebLayout;

  const WebLayoutWrapper({
    super.key,
    required this.child,
    this.forceWebLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    // 웹에서는 고정 크기로 중앙 정렬 (모바일 화면처럼)
    if (kIsWeb || forceWebLayout) {
      return Scaffold(
        backgroundColor: const Color(0xFF242424),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF242424), Color(0xFF5E605F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 450,
                maxHeight: 900,
              ),
              width: 450,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 50,
                    spreadRadius: 0,
                  )
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: child,
            ),
          ),
        ),
      );
    }

    return child;
  }
}

