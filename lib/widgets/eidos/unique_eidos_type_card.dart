import 'package:flutter/material.dart';
import 'package:innerfive/widgets/firebase_image.dart';

class UniqueEidosTypeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  final String? description;
  final List<String>? keywords;

  const UniqueEidosTypeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
    this.description,
    this.keywords,
  });

  /// 텍스트를 읽기 쉽게 단락으로 나누는 함수
  String _formatDescription(String text) {
    // 이중 마침표(..) 정리
    String cleanText = text.replaceAll('..', '.');

    // 문장 단위로 나누기 (. 다음에 공백이 있는 경우)
    final sentences = cleanText.split(RegExp(r'\.\s+'));

    // 빈 문장 제거하고 각 문장 끝에 마침표 추가
    final validSentences = sentences
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim().endsWith('.') ? s.trim() : '${s.trim()}.')
        .toList();

    if (validSentences.length <= 1) {
      return cleanText; // 문장이 1개 이하면 그대로 반환
    }

    // 각 문장을 별도 줄로 만들어서 가독성 향상
    return validSentences.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    print('🎴🎴🎴 === UNIQUE EIDOS TYPE CARD BUILD DEBUG ===');
    print('🎴 Card Title: "$title"');
    print('🎴 Card Image URL: "$imageUrl"');
    print('🎴 Card Description: "${description ?? 'null'}"');
    print('🎴 Keywords: ${keywords?.toString() ?? 'null'}');
    print('🎴 Title isEmpty: ${title.isEmpty}');
    print('🎴 ImageUrl isEmpty: ${imageUrl.isEmpty}');
    print('🎴🎴🎴 === STARTING CARD RENDER ===');

    return AspectRatio(
      aspectRatio: 0.5, // 1:2 비율 (width:height = 1:2) - FortuneCard와 동일
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 1. Background Image
              if (imageUrl.isNotEmpty) ...[
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      print('🎴 Rendering FirebaseImage with URL: $imageUrl');
                      return FirebaseImage(
                        storageUrl: imageUrl,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                )
              ] else ...[
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      print('🎴 Using fallback background (grey)');
                      return Container(color: Colors.grey[900]);
                    },
                  ),
                ),
              ],

              // 2. Content Scrim - FortuneCard와 동일한 그라디언트
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(128),
                        Colors.black.withAlpha(240),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Content - FortuneCard와 동일한 레이아웃
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Builder(
                  builder: (context) {
                    print('🎴 Rendering content section');
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 3), // 상단 여백
                        Row(
                          children: [
                            Icon(
                              Icons.psychology, // 에이도스 타입을 나타내는 아이콘
                              color: Colors.white.withAlpha(150),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Unique Type',
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            print('🎴 Rendering title: "$title"');
                            return Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Personal Eidos Essence',
                          style: TextStyle(
                            color: Colors.white.withAlpha(128),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          width: 50,
                          color: Colors.white.withAlpha(64),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final displayText = description ??
                                  'Discover your unique cosmic essence and personal characteristics.';
                              print(
                                  '🎴 Rendering description: "${displayText.substring(0, displayText.length > 50 ? 50 : displayText.length)}..."');
                              return Text(
                                displayText,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(136),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
