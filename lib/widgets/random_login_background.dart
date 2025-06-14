import 'package:flutter/material.dart';
import 'package:innerfive/widgets/gradient_blurred_background.dart';
import '../services/image_service.dart';

class RandomLoginBackground extends StatefulWidget {
  final Widget child;
  final BoxFit fit;

  const RandomLoginBackground({
    super.key,
    required this.child,
    this.fit = BoxFit.cover,
  });

  @override
  State<RandomLoginBackground> createState() => _RandomLoginBackgroundState();
}

class _RandomLoginBackgroundState extends State<RandomLoginBackground> {
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomBackground();
  }

  Future<void> _loadRandomBackground() async {
    try {
      final url = await ImageService.getRandomLoginBackground();
      if (mounted) {
        setState(() {
          _imageUrl = url;
          _isLoading = false;
        });
        if (url != null) {
          print('Loading image URL: $url');
        }
      }
    } catch (e) {
      print('Error loading random background: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBlurredBackground(
      imageUrl: _imageUrl,
      isLoading: _isLoading,
      blurStrength: 8.0, // 더 강한 블러 효과
      overlayOpacity: 0.9, // 더 강한 다크 오버레이 (90%)
      child: widget.child,
    );
  }
}
