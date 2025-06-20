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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Unique Type',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title, // Display the specific Eidos type name
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 설명 표시
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description!, // Show the full description without simplification
              style: TextStyle(
                color: Colors.white.withAlpha(220),
                fontSize: 15,
                height: 1.4,
              ),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              'No description available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
