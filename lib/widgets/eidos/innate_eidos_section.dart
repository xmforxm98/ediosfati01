import 'package:flutter/material.dart';
import 'package:innerfive/models/detailed_report.dart';
import 'package:innerfive/widgets/eidos/info_card.dart';

class InnateEidosSection extends StatelessWidget {
  final InnateEidos? innateEidos;

  const InnateEidosSection({super.key, required this.innateEidos});

  @override
  Widget build(BuildContext context) {
    if (innateEidos == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Your Innate Nature',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTextBlock('Core Energy', innateEidos!.coreEnergyText),
        _buildTextBlock('Latent Talent', innateEidos!.talentText),
        _buildTextBlock('Inner Desires', innateEidos!.desireText),
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
