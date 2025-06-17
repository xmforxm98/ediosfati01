import 'package:flutter/material.dart';
import 'package:innerfive/services/image_service.dart';

class InitialBackground extends StatefulWidget {
  final Widget child;

  const InitialBackground({super.key, required this.child});

  @override
  State<InitialBackground> createState() => _InitialBackgroundState();
}

class _InitialBackgroundState extends State<InitialBackground> {
  String? _backgroundUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackground();
  }

  Future<void> _loadBackground() async {
    try {
      final url = await ImageService.getSecondBackgroundUrl();
      if (mounted) {
        setState(() {
          _backgroundUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading initial background: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (_backgroundUrl != null && !_isLoading)
            Image.network(
              _backgroundUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading background image: $error');
                return Container();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white.withOpacity(0.5),
                  ),
                );
              },
            )
          else if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          // Child content
          widget.child,
        ],
      ),
    );
  }
}
