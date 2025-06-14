import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const CustomErrorMessage({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.3), // 30% 투명도
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (onDismiss != null)
                          GestureDetector(
                            onTap: onDismiss,
                            child: Icon(
                              Icons.close,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .slideY(begin: 1.0, end: 0.0, duration: 300.ms, curve: Curves.easeOut)
        .fadeIn(duration: 200.ms);
  }

  /// 오류 메시지를 표시하는 헬퍼 메서드
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => CustomErrorMessage(
            message: message,
            onDismiss: () => overlayEntry.remove(),
          ),
    );

    overlay.insert(overlayEntry);

    // 3초 후 자동으로 제거
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
