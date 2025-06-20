import 'package:flutter/material.dart';
import 'package:innerfive/models/detailed_report.dart';
import 'package:innerfive/widgets/eidos/career_profile_section.dart';
import 'package:innerfive/widgets/eidos/innate_eidos_section.dart';
import 'package:innerfive/widgets/eidos/journey_section.dart';
import 'package:innerfive/widgets/eidos/personality_profile_section.dart';
import 'package:innerfive/widgets/eidos/relationship_insight_section.dart';
import 'package:innerfive/widgets/eidos/tarot_insight_section.dart';

class DetailedReportScreen extends StatelessWidget {
  final DetailedReport detailedReport;

  const DetailedReportScreen({super.key, required this.detailedReport});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(detailedReport.eidosSummary.summaryTitle),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Personalized Introduction",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(detailedReport.personalizedIntroduction.opening ?? ''),
            const SizedBox(height: 16),
            Text(
              "Core Identity",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(detailedReport.coreIdentitySection.text),
            const SizedBox(height: 16),
            Text(
              "Strengths",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...detailedReport.strengthsSection.points.map((p) => Text('• $p')),
            const SizedBox(height: 16),
            Text(
              "Growth Areas",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...detailedReport.growthAreasSection.points
                .map((p) => Text('• $p')),
            const SizedBox(height: 16),
            Text(
              "Life Guidance",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(detailedReport.lifeGuidanceSection.text),
          ],
        ),
      ),
    );
  }
}
