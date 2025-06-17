import 'package:flutter/material.dart';
import 'package:innerfive/models/detailed_report.dart';
import 'package:innerfive/widgets/eidos/info_card.dart';

class JourneySection extends StatelessWidget {
  final Journey? journey;

  const JourneySection({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    if (journey == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Your Life\'s Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTextBlock('Major Life Cycle (Daeun)', journey!.daeunText),
        _buildTextBlock('Current Year\'s Theme', journey!.currentYearText),
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
