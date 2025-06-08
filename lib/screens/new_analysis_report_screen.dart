import 'package:flutter/material.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:fl_chart/fl_chart.dart';

class NewAnalysisReportScreen extends StatelessWidget {
  final NarrativeReport report;

  const NewAnalysisReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.eidosSummary.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiveElementsBarChart(report.fiveElementsStrength),
            const SizedBox(height: 24),
            _buildEidosSummary(context, report.eidosSummary),
            const SizedBox(height: 24),
            _buildInnateEidos(context, report.innateEidos),
            const SizedBox(height: 24),
            _buildJourney(context, report.journey),
            const SizedBox(height: 24),
            _buildTarotInsight(context, report.tarotInsight),
            const SizedBox(height: 24),
            _buildRyusWisdom(context, report.ryusWisdom),
            const SizedBox(height: 24),
            _buildPersonalityProfile(context, report.personalityProfile),
            const SizedBox(height: 24),
            _buildRelationshipInsight(context, report.relationshipInsight),
            const SizedBox(height: 24),
            _buildCareerProfile(context, report.careerProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildFiveElementsBarChart(Map<String, dynamic> fiveElementsStrength) {
    final elements = ['Wood', 'Fire', 'Earth', 'Metal', 'Water'];
    final colors = [
      Colors.green,
      Colors.red,
      Colors.brown,
      Colors.grey,
      Colors.blue,
    ];

    final double maxY =
        fiveElementsStrength.values.isEmpty
            ? 5.0
            : (fiveElementsStrength.values
                        .map((v) => v is num ? v : 0)
                        .reduce((a, b) => a > b ? a : b) +
                    1)
                .toDouble();

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Five Elements Strength',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          return Text(
                            elements[idx],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(elements.length, (idx) {
                    final element = elements[idx];
                    final value =
                        (fiveElementsStrength[element] ?? 0).toDouble();
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          color: colors[idx],
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEidosSummary(BuildContext context, EidosSummary summary) {
    return _buildSectionCard(
      context,
      title: summary.title,
      children: [
        Text(
          summary.summaryTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.blueAccent),
        ),
        const SizedBox(height: 8),
        Text(
          summary.summaryText,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 16),
        Text(
          summary.currentEnergyTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.blueAccent),
        ),
        const SizedBox(height: 8),
        Text(
          summary.currentEnergyText,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildInnateEidos(BuildContext context, InnateEidos eidos) {
    return _buildSectionCard(
      context,
      title: eidos.title,
      children: [
        _buildAttributeRow(
          context,
          eidos.coreEnergyTitle,
          eidos.coreEnergyText,
        ),
        _buildAttributeRow(context, eidos.talentTitle, eidos.talentText),
        _buildAttributeRow(context, eidos.desireTitle, eidos.desireText),
      ],
    );
  }

  Widget _buildJourney(BuildContext context, Journey journey) {
    return _buildSectionCard(
      context,
      title: journey.title,
      children: [
        _buildAttributeRow(context, journey.daeunTitle, journey.daeunText),
        _buildAttributeRow(
          context,
          journey.currentYearTitle,
          journey.currentYearText,
        ),
      ],
    );
  }

  Widget _buildTarotInsight(BuildContext context, TarotInsight insight) {
    return _buildSectionCard(
      context,
      title: insight.title,
      children: [
        _buildAttributeRow(context, insight.cardTitle, insight.cardMeaning),
        _buildAttributeRow(
          context,
          insight.cardMessageTitle,
          insight.cardMessageText,
        ),
      ],
    );
  }

  Widget _buildRyusWisdom(BuildContext context, RyusWisdom wisdom) {
    return _buildSectionCard(
      context,
      title: wisdom.title,
      children: [
        Text(
          wisdom.message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityProfile(
    BuildContext context,
    PersonalityProfile profile,
  ) {
    return _buildSectionCard(
      context,
      title: profile.title == 'N/A' ? 'Personality Profile' : profile.title,
      children: [
        _buildAttributeRow(context, 'Core Traits', profile.coreTraits),
        _buildAttributeRow(context, 'Likes', profile.likes),
        _buildAttributeRow(context, 'Dislikes', profile.dislikes),
        _buildAttributeRow(
          context,
          'Relationship Style',
          profile.relationshipStyle,
        ),
        _buildAttributeRow(context, 'Inner Shadow', profile.shadow),
      ],
    );
  }

  Widget _buildRelationshipInsight(
    BuildContext context,
    RelationshipInsight insight,
  ) {
    return _buildSectionCard(
      context,
      title: insight.title == 'N/A' ? 'Relationship Insight' : insight.title,
      children: [
        _buildAttributeRow(context, 'Love Style', insight.loveStyle),
        _buildAttributeRow(context, 'Ideal Partner', insight.idealPartner),
        _buildAttributeRow(
          context,
          'Relationship Advice',
          insight.relationshipAdvice,
        ),
      ],
    );
  }

  Widget _buildCareerProfile(BuildContext context, CareerProfile profile) {
    return _buildSectionCard(
      context,
      title: profile.title == 'N/A' ? 'Career Profile' : profile.title,
      children: [
        _buildAttributeRow(context, 'Career Aptitude', profile.aptitude),
        _buildAttributeRow(context, 'Work Style', profile.workStyle),
        _buildAttributeRow(
          context,
          'Success Strategy',
          profile.successStrategy,
        ),
      ],
    );
  }

  Widget _buildAttributeRow(BuildContext context, String title, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
