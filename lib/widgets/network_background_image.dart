import 'package:flutter/material.dart';
import '../services/image_service.dart';

class NetworkBackgroundImage extends StatefulWidget {
  final String imageName;
  final Widget child;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const NetworkBackgroundImage({
    super.key,
    required this.imageName,
    required this.child,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<NetworkBackgroundImage> createState() => _NetworkBackgroundImageState();
}

class _NetworkBackgroundImageState extends State<NetworkBackgroundImage> {
  String? imageUrl;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final url = await ImageService.getImageUrl(widget.imageName);
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
                  Text(
                    '이미지를 불러올 수 없습니다',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadImage,
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

/// 간편하게 사용할 수 있는 헬퍼 함수
Widget buildNetworkBackgroundImage({
  required String imageName,
  required Widget child,
  BoxFit fit = BoxFit.cover,
  Widget? loadingWidget,
  Widget? errorWidget,
}) {
  return NetworkBackgroundImage(
    imageName: imageName,
    fit: fit,
    loadingWidget: loadingWidget,
    errorWidget: errorWidget,
    child: child,
  );
}
