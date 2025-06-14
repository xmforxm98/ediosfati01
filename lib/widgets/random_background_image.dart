import 'package:flutter/material.dart';
import '../services/image_service.dart';

class RandomBackgroundImage extends StatefulWidget {
  final List<String> imageNames;
  final Widget child;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const RandomBackgroundImage({
    super.key,
    required this.imageNames,
    required this.child,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<RandomBackgroundImage> createState() => _RandomBackgroundImageState();
}

class _RandomBackgroundImageState extends State<RandomBackgroundImage> {
  String? imageUrl;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRandomImage();
  }

  Future<void> _loadRandomImage() async {
    try {
      final url = await ImageService.getRandomImageFromGroup(widget.imageNames);
      if (mounted) {
        setState(() {
          imageUrl = url;
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child:
            widget.loadingWidget ??
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (hasError || imageUrl == null) {
      return Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child:
            widget.errorWidget ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '이미지를 불러올 수 없습니다',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadRandomImage,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(imageUrl!), fit: widget.fit),
      ),
      child: widget.child,
    );
  }
}

/// 랜덤 로그인 배경 이미지 헬퍼 위젯
class RandomLoginBackground extends StatelessWidget {
  final Widget child;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const RandomLoginBackground({
    super.key,
    required this.child,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return RandomBackgroundImage(
      imageNames: const ['login1', 'login2', 'login3', 'login4'],
      fit: fit,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      child: child,
    );
  }
}
