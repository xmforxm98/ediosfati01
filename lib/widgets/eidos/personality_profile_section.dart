import 'package:flutter/material.dart';
import 'package:innerfive/models/detailed_report.dart';
import 'package:innerfive/widgets/eidos/info_card.dart';

class PersonalityProfileSection extends StatelessWidget {
  final PersonalityProfile? personalityProfile;

  const PersonalityProfileSection(
      {super.key, required this.personalityProfile});

  @override
  Widget build(BuildContext context) {
    if (personalityProfile == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Personality Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTextBlock('Core Traits', personalityProfile!.coreTraits),
        _buildTextBlock('Likes', personalityProfile!.likes),
        _buildTextBlock('Dislikes', personalityProfile!.dislikes),
        _buildTextBlock(
            'Relationship Style', personalityProfile!.relationshipStyle),
        _buildTextBlock('Shadow Self', personalityProfile!.shadow),
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
