import 'package:flutter/material.dart';
import 'dart:math' as math;

class EidosCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onTap;
  final bool isRevealed;
  final bool isReversed;
  final String? description;
  final List<String>? keywords;

  const EidosCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.onTap,
    this.isRevealed = false,
    this.isReversed = false,
    this.description,
    this.keywords,
  });

  @override
  State<EidosCard> createState() => _EidosCardState();
}

class _EidosCardState extends State<EidosCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(EidosCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 280,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber
                        .withAlpha((255 * 0.3 * _glowAnimation.value).round()),
                    blurRadius: 20 + (10 * _glowAnimation.value),
                    spreadRadius: 2 + (3 * _glowAnimation.value),
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.5).round()),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // 카드 뒷면
                    if (_flipAnimation.value < 0.5) _buildCardBack(),

                    // 카드 앞면
                    if (_flipAnimation.value >= 0.5)
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(math.pi),
                        child: _buildCardFront(),
                      ),

                    // 카드 테두리
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amber.withAlpha((255 * 0.6).round()),
                          width: 2,
                        ),
                      ),
                    ),

                    // 터치 효과
                    if (!widget.isRevealed)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withAlpha((255 * 0.1).round()),
                              Colors.transparent,
                              Colors.amber.withAlpha((255 * 0.1).round()),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.touch_app,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(child: CustomPaint(painter: MysticPatternPainter())),

          // 중앙 심볼
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withAlpha((255 * 0.8).round()),
                        Colors.amber.withAlpha((255 * 0.3).round()),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'EIDOS',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'FATI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade100],
        ),
      ),
      child: Column(
        children: [
          // 상단 타이틀
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withAlpha((255 * 0.8).round()),
                  Colors.orange.withAlpha((255 * 0.6).round()),
                ],
              ),
            ),
            child: Text(
              widget.title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 이미지 영역
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.2).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // 배경 이미지
                    Positioned.fill(
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.amber,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // 설명 오버레이 (카드가 공개되었을 때만)
                    if (widget.isRevealed &&
                        (widget.description != null || widget.keywords != null))
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(128),
                                Colors.black.withAlpha(200),
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 설명 텍스트
                                if (widget.description != null) ...[
                                  Text(
                                    widget.description!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // 키워드 태그들
                                if (widget.keywords != null &&
                                    widget.keywords!.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children:
                                        widget.keywords!.take(3).map((keyword) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withAlpha(200),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          keyword,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 하단 장식
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withAlpha((255 * 0.3).round()),
                  Colors.orange.withAlpha((255 * 0.2).round()),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildOrnament(), _buildOrnament(), _buildOrnament()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnament() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.amber.withAlpha((255 * 0.8).round()),
            Colors.amber.withAlpha((255 * 0.3).round()),
          ],
        ),
      ),
      child: const Icon(Icons.star, color: Colors.amber, size: 12),
    );
  }
}

class MysticPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withAlpha((255 * 0.1).round())
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // 동심원 그리기
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, i * 30.0, paint);
    }

    // 방사형 선 그리기
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final start = Offset(
        center.dx + math.cos(angle) * 50,
        center.dy + math.sin(angle) * 50,
      );
      final end = Offset(
        center.dx + math.cos(angle) * 150,
        center.dy + math.sin(angle) * 150,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
