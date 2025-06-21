import 'package:flutter/material.dart';
import 'package:innerfive/utils/text_formatting_utils.dart';
import 'package:innerfive/widgets/firebase_image.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl; // Optional image

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  // 텍스트를 단락별로 나누어 읽기 쉽게 만드는 함수
  String _formatTextWithParagraphs(String text) {
    // 기존 줄바꿈 제거하고 문장 단위로 분리
    String cleanText =
        text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    // 문장 끝 패턴 (마침표, 느낌표, 물음표 뒤에 공백이나 문자열 끝)
    List<String> sentences = cleanText.split(RegExp(r'(?<=[.!?])\s+'));

    if (sentences.length <= 2) {
      return cleanText; // 문장이 2개 이하면 그대로 반환
    }

    List<String> paragraphs = [];
    String currentParagraph = '';

    for (int i = 0; i < sentences.length; i++) {
      String sentence = sentences[i].trim();
      if (sentence.isEmpty) continue;

      if (currentParagraph.isEmpty) {
        currentParagraph = sentence;
      } else {
        currentParagraph += ' $sentence';
      }

      // 2-3문장마다 또는 길이가 200자 이상일 때 단락 나누기
      if ((i + 1) % 2 == 0 && currentParagraph.length > 150) {
        paragraphs.add(currentParagraph);
        currentParagraph = '';
      }
    }

    // 남은 문장이 있으면 추가
    if (currentParagraph.isNotEmpty) {
      paragraphs.add(currentParagraph);
    }

    return paragraphs.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // 🔍 DEBUG: 카드 렌더링 상태 확인
      print('📋 Rendering card: "$title" (${description.length} chars)');

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 이미지 영역 (있을 때만 표시)
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FirebaseImage(
                        storageUrl: imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

              // 텍스트 영역
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 설명 (단락 나누기 및 포맷팅 적용)
                    TextFormattingUtils.buildFormattedText(
                      _formatTextWithParagraphs(description),
                      style: TextStyle(
                        color: Colors.white.withAlpha(136),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
