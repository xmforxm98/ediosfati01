import 'package:flutter/material.dart';
import 'package:innerfive/widgets/firebase_image.dart';
import 'package:innerfive/utils/text_formatting_utils.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // width 100%
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 이미지 영역 (내부 마스크 적용)
              Container(
                padding: const EdgeInsets.all(16), // 카드 안쪽 여백
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16), // 내부 이미지 radius
                  child: AspectRatio(
                    aspectRatio: 0.5, // 1:2 비율 (width:height = 1:2)
                    child: SizedBox(
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? FirebaseImage(
                              storageUrl: imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey[900]),
                    ),
                  ),
                ),
              ),

              // 하단 텍스트 영역 (간결하게 정리)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Colors.white.withAlpha(150),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your Unique Type',
                            style: TextStyle(
                              color: Colors.white.withAlpha(150),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
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
                    const SizedBox(height: 20),

                    // Read more 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(26),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Read more',
                              style: TextStyle(
                                color: Colors.white.withAlpha(230),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withAlpha(230),
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
