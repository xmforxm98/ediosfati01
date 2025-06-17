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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF242424), Color(0xFF121212)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Detailed Report',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            SliverToBoxAdapter(
              child: InnateEidosSection(
                innateEidos: detailedReport.innateEidos,
              ),
            ),
            SliverToBoxAdapter(
              child: PersonalityProfileSection(
                personalityProfile: detailedReport.personalityProfile,
              ),
            ),
            SliverToBoxAdapter(
              child: RelationshipInsightSection(
                relationshipInsight: detailedReport.relationshipInsight,
              ),
            ),
            SliverToBoxAdapter(
              child: CareerProfileSection(
                careerProfile: detailedReport.careerProfile,
              ),
            ),
            SliverToBoxAdapter(
              child: JourneySection(
                journey: detailedReport.journey,
              ),
            ),
            SliverToBoxAdapter(
              child: TarotInsightSection(
                tarotInsight: detailedReport.tarotInsight,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
