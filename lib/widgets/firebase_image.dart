import 'package:flutter/material.dart';
import 'package:innerfive/services/image_service.dart';

class FirebaseImage extends StatefulWidget {
  final String? storageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const FirebaseImage({
    super.key,
    required this.storageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<FirebaseImage> createState() => _FirebaseImageState();
}

class _FirebaseImageState extends State<FirebaseImage> {
  Future<String?>? _authenticatedUrlFuture;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  @override
  void didUpdateWidget(covariant FirebaseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.storageUrl != oldWidget.storageUrl) {
      _loadUrl();
    }
  }

  void _loadUrl() {
    print('FirebaseImage: Loading URL: ${widget.storageUrl}');

    if (widget.storageUrl == null || widget.storageUrl!.isEmpty) {
      print('FirebaseImage: No URL provided');
      _authenticatedUrlFuture = Future.value(null);
      return;
    }

    final urlString = widget.storageUrl!;

    // 이미 완전한 HTTP URL인 경우 바로 사용
    if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
      print('FirebaseImage: Using complete URL directly: $urlString');
      _authenticatedUrlFuture = Future.value(urlString);
      return;
    }

    // Firebase Storage 경로인 경우 변환
    try {
      print('FirebaseImage: Converting Firebase path to URL: $urlString');
      setState(() {
        _authenticatedUrlFuture =
            ImageService.getImageUrl(urlString, isFullPath: true);
      });
    } catch (e) {
      print('FirebaseImage: Error converting path: $e');
      _authenticatedUrlFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authenticatedUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ??
              SizedBox.expand(
                child: Container(
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return widget.errorWidget ??
              SizedBox.expand(
                child: Container(
                  color: Colors.grey[900],
                  child: const Center(child: Icon(Icons.error_outline)),
                ),
              );
        }

        final url = snapshot.data!;
        return Image.network(
          url,
          fit: widget.fit,
          alignment: Alignment.center,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return widget.placeholder ??
                SizedBox.expand(
                  child: Container(
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                );
          },
          errorBuilder: (context, error, stackTrace) {
            return widget.errorWidget ??
                SizedBox.expand(
                  child: Container(
                    color: Colors.grey[900],
                    child: const Center(child: Icon(Icons.error_outline)),
                  ),
                );
          },
        );
      },
    );
  }
}
