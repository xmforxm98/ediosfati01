import 'package:flutter/material.dart';
import 'package:innerfive/models/detailed_report.dart';
import 'package:innerfive/widgets/eidos/info_card.dart';

class TarotInsightSection extends StatelessWidget {
  final TarotInsight? tarotInsight;

  const TarotInsightSection({super.key, required this.tarotInsight});

  @override
  Widget build(BuildContext context) {
    if (tarotInsight == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Tarot Insight',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTextBlock(tarotInsight!.cardTitle, tarotInsight!.cardMessageText),
      ],
    );
  }

  Widget _buildTextBlock(String title, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
