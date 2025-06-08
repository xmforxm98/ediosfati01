import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension WidgetAnimationExtensions on Widget {
  /// Applies a fade-in and slide-up animation.
  ///
  /// - `delay`: A delay before the animation starts.
  /// - `duration`: The duration of the animation.
  /// - `curve`: The curve of the animation.
  Widget animateOnPageLoad({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) {
    final effectiveDuration = duration ?? 600.ms;
    return animate(delay: delay)
        .fadeIn(duration: effectiveDuration, curve: curve ?? Curves.easeOut)
        .slideY(
          begin: 0.5,
          end: 0,
          duration: effectiveDuration,
          curve: curve ?? Curves.easeOut,
        );
  }
}
