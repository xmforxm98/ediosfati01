import 'package:flutter/material.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/screens/eidos_analysis_screen.dart';
import 'package:innerfive/screens/eidos_card_screen.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:innerfive/services/improved_eidos_extractor.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:innerfive/services/image_service.dart';
import 'package:innerfive/widgets/eidos_card.dart';
import 'package:innerfive/widgets/gradient_blurred_background.dart';

class NewAnalysisReportScreen extends StatelessWidget {
  final NarrativeReport report;
  final UserData? userData;
  final Map<String, dynamic>? analysisData;

  const NewAnalysisReportScreen({
    super.key,
    required this.report,
    this.userData,
    this.analysisData,
  });

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
            _buildEidosGroupSection(context),
            const SizedBox(height: 24),
            _buildEidosCardSection(context),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
            _buildEidosAnalysisButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEidosCardSection(BuildContext context) {
    // Get Eidos type from report
    String? eidosType = report.eidosType ?? report.eidosSummary.eidosType;

    // Debug logs removed - feature working correctly

    // If no eidos type found, try to extract from analysis data using EidosExtractor
    if (eidosType == null && analysisData != null) {
      eidosType = ImprovedEidosExtractor.extractEidosType(analysisData!);
    }

    // If still no eidos type, provide a fallback
    if (eidosType == null || eidosType.isEmpty) {
      eidosType =
          'The Inspired Verdant Architect of Green Mercenary'; // Default fallback
      print('⚠️ Using fallback Eidos Type: $eidosType');
    } else {
      print('✅ Using Eidos Type: $eidosType');
    }

    // Ensure we have a non-null eidosType
    final String finalEidosType = eidosType;

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your Eidos Card',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Discover your mystical Eidos card based on your unique energy signature.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withAlpha(64),
                    Colors.orange.withAlpha(32),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withAlpha(128),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.style, color: Colors.amber, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    finalEidosType.split(' of ').last,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to reveal your card',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EidosCardScreen(
                        eidosType: finalEidosType,
                        analysisData: analysisData ?? {},
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Reveal My Eidos Card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.withAlpha(51),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
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

    final double maxY = fiveElementsStrength.values.isEmpty
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
                    leftTitles: const AxisTitles(
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
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
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
                          color: colors[idx].withAlpha((255 * 0.8).round()),
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

  Widget _buildEidosGroupSection(BuildContext context) {
    // Use the same logic as _buildEidosCardSection to extract Eidos type
    String? eidosType = report.eidosType ?? report.eidosSummary.eidosType;

    // If no eidos type found, try to extract from analysis data using ImprovedEidosExtractor
    if (eidosType == null && analysisData != null) {
      eidosType = ImprovedEidosExtractor.extractEidosType(analysisData!);
    }

    // If still no eidos type, provide a fallback
    if (eidosType == null || eidosType.isEmpty) {
      eidosType =
          'The Inspired Verdant Architect of Green Mercenary'; // Default fallback
    }

    // Extract group name from eidosType (e.g., "The Inspired Verdant Architect of Golden Sage" -> "Golden Sage")
    String groupName = 'Green Mercenary'; // default
    if (eidosType.contains(' of ')) {
      groupName = eidosType.split(' of ').last;
    }

    // Map group name to group info
    final groupInfo = _getGroupInfoFromName(groupName);
    final userName = userData?.nickname ?? userData?.firstName ?? 'Seeker';

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withAlpha(64),
              Colors.blue.withAlpha(64),
              Colors.indigo.withAlpha(64),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(32),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      groupName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '$userName\'s Eidos Group',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                groupInfo['display_name'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                groupInfo['description'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(128),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              // Group Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    groupInfo['image_url'] as String,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.amber,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withAlpha(32),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: Colors.white54,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image Loading Failed',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This group image symbolically represents your Eidos essence.',
                        style: TextStyle(
                          color: Colors.white.withAlpha(128),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEidosAnalysisButton(BuildContext context) {
    if (userData == null || analysisData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Discover Your Eidos Essence',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock the deeper layers of your destiny by revealing your unique Eidos type from 60 possible essences. Share your thoughts and concerns to receive personalized guidance.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Reveal My Eidos Essence',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EidosAnalysisScreen(
                      userData: userData!,
                      analysisData: analysisData!,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.amber.withAlpha(51),
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get group info from group name
  Map<String, dynamic> _getGroupInfoFromName(String groupName) {
    // 기존 EidosGroupService의 URL 구조 사용
    switch (groupName) {
      case 'Golden Sage':
        return {
          'display_name': 'Golden Sage',
          'description':
              'Wise beings who seek knowledge and enlightenment through deep understanding',
          'image_url':
              'https://storage.googleapis.com/innerfive.firebasestorage.app/eidos_group_images/golden_pioneer1.png',
        };
      case 'Red Phoenix':
        return {
          'display_name': 'Red Phoenix',
          'description':
              'Passionate beings who rise from challenges with renewed strength and creativity',
          'image_url':
              'https://storage.googleapis.com/innerfive.firebasestorage.app/eidos_group_images/advanced_integration1.png',
        };
      case 'Blue Scholar':
        return {
          'display_name': 'Blue Scholar',
          'description':
              'Analytical beings who pursue truth through careful study and reflection',
          'image_url':
              'https://storage.googleapis.com/innerfive.firebasestorage.app/eidos_group_images/mastery_transcendence1.png',
        };
      case 'Black Panther':
        return {
          'display_name': 'Black Panther',
          'description':
              'Powerful beings who move with stealth and strike with precision',
          'image_url':
              'https://storage.googleapis.com/innerfive.firebasestorage.app/eidos_group_images/mastery_transcendence2.png',
        };
      case 'Green Mercenary':
      default:
        return {
          'display_name': 'Green Mercenary',
          'description':
              'Beings who harmonize with the forces of nature and pioneer new paths',
          'image_url':
              'https://storage.googleapis.com/innerfive.firebasestorage.app/eidos_group_images/green_mercenary1.png',
        };
    }
  }
}
