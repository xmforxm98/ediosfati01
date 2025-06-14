import 'dart:ui';
import 'package:flutter/material.dart';

class GradientBlurredBackground extends StatelessWidget {
  final String? imageUrl;
  final Widget child;
  final bool isLoading;
  final double blurStrength;
  final double overlayOpacity;

  const GradientBlurredBackground({
    super.key,
    required this.imageUrl,
    required this.child,
    this.isLoading = false,
    this.blurStrength = 5.0,
    this.overlayOpacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final imageStack =
        imageUrl == null
            ? <Widget>[Container(color: Colors.black)]
            : <Widget>[
              // 1. Fully blurred background
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurStrength,
                  sigmaY: blurStrength,
                ),
                child: Image.network(
                  imageUrl!,
                  key: ValueKey('${imageUrl!}-blur'),
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Container(color: Colors.black),
                ),
              ),

              // 2. The original image on top, masked to create a gradient blur effect
              ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.transparent, Colors.black],
                    stops: [
                      0.0,
                      0.5,
                    ], // The blur will be full at the bottom, and gone by 50% height
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.network(
                  imageUrl!,
                  key: ValueKey('${imageUrl!}-clear'),
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Container(color: Colors.black),
                ),
              ),
            ];

    return Stack(
      fit: StackFit.expand,
      children: [
        ...imageStack,
        // 3. Dark gradient overlay for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(overlayOpacity),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6],
            ),
          ),
        ),

        // 4. The UI content
        child,
      ],
    );
  }
}
