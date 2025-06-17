import 'package:flutter/material.dart';
import 'package:innerfive/models/detailed_report.dart';

class RelationshipInsightSection extends StatelessWidget {
  final RelationshipInsight? relationshipInsight;

  const RelationshipInsightSection(
      {super.key, required this.relationshipInsight});

  @override
  Widget build(BuildContext context) {
    if (relationshipInsight == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Relationship Insight',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTextBlock('Love Style', relationshipInsight!.loveStyle),
        _buildTextBlock('Ideal Partner', relationshipInsight!.idealPartner),
        _buildTextBlock(
            'Relationship Advice', relationshipInsight!.relationshipAdvice),
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
