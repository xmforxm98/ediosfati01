import 'package:flutter/material.dart';

class TextFormattingUtils {
  /// **텍스트** 형식을 굵게 표시하는 RichText 위젯을 생성합니다.
  static Widget buildFormattedText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');

    int lastMatchEnd = 0;

    for (final Match match in boldPattern.allMatches(text)) {
      // 일반 텍스트 추가
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }

      // 굵은 텍스트 추가
      spans.add(TextSpan(
        text: match.group(1) ?? '',
        style: style?.copyWith(fontWeight: FontWeight.bold) ??
            const TextStyle(fontWeight: FontWeight.bold),
      ));

      lastMatchEnd = match.end;
    }

    // 마지막 일반 텍스트 추가
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
