import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/services/eidos_group_service.dart';
import 'package:fl_chart/fl_chart.dart';

class MyReportScreen extends StatefulWidget {
  const MyReportScreen({super.key});

  @override
  State<MyReportScreen> createState() => _MyReportScreenState();
}

class _MyReportScreenState extends State<MyReportScreen> {
  Future<Map<String, dynamic>?>? _reportFuture;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchLatestReport();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _fetchLatestReport() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _reportFuture = _getReportFromFirestore(user.uid);
      });
    }
  }

  Future<Map<String, dynamic>?> _getReportFromFirestore(String userId) async {
    try {
      print("Fetching report for user: $userId");

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        print("Found reading data with keys: ${data.keys.toList()}");
        return data;
      }

      return null;
    } catch (e) {
      print("Error fetching report: $e");
      rethrow;
    }
  }

  void _goToFirstPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToSecondPage() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }

          if (snapshot.hasError) {
            return ErrorView(
              error: snapshot.error.toString(),
              onRetry: _fetchLatestReport,
            );
          }

          final reportData = snapshot.data;
          if (reportData == null || !reportData.containsKey('report')) {
            return const NoReportView();
          }

          // Create NarrativeReport from the report data
          final report = NarrativeReport.fromJson(
            reportData['report'] as Map<String, dynamic>,
          );

          return PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // First Page: Eidos Group Background
              EidosGroupBackgroundView(
                report: report,
                onScrollHint: _goToSecondPage,
              ),
              // Second Page: Report Content
              ReportContentPage(
                report: report,
                onBackToGroup: _goToFirstPage,
              ),
            ],
          );
        },
      ),
    );
  }
}

// Loading state widget
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}

// Error state widget
class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading report: $error',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// No report state widget
class NoReportView extends StatelessWidget {
  const NoReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No analysis report found.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

// Main group background view
class EidosGroupBackgroundView extends StatelessWidget {
  final NarrativeReport report;
  final VoidCallback? onScrollHint;

  const EidosGroupBackgroundView({
    super.key,
    required this.report,
    this.onScrollHint,
  });

  String _generateImageUrl(String imageGroup, int seed) {
    final fileNameMapping = {
      'abyss_explorer': 'Abyss_Explorer',
      'compassionate_healer': 'Compassionate_Healer',
      'creative_affluent': 'Creative_Affluent',
      'deep_rooted_nurturer': 'Deep_rooted_Nurturer',
      'destiny_integrator': 'Destiny_Integrator',
      'flexible_strategist': 'Flexible_Strategist',
      'free_innovator': 'Free_Innovator',
      'golden_pioneer': 'Golden_Pioneer',
      'great_manifestor': 'Great_Manifestor',
      'green_mercenary': 'Green_Mercenary',
      'honorable_strategist': 'Honorable_Strategist',
      'indomitable_explorer': 'Indomitable_Explorer',
      'inner_alchemist': 'Inner_Alchemist',
      'radiant_creator': 'Radiant_Creator',
      'relationship_artisan': 'Relationship_Artisan',
      'resolute_designer': 'Resolute_Designer',
      'spiritual_enlightener': 'Spiritual_Enlightener',
      'strong_willed_lighthouse': 'Strong_willed_Lighthouse',
      'wise_guide': 'Wise_Guide',
      'wise_ruler': 'Wise_Ruler',
    };

    final fileName = fileNameMapping[imageGroup] ?? 'Radiant_Creator';
    final variation = (seed % 4) + 1;

    return 'https://storage.googleapis.com/innerfive.firebasestorage.app/edios_group_image/$fileName$variation.png';
  }

  @override
  Widget build(BuildContext context) {
    // Extract eidos type name from report
    String? eidosTypeName = report.eidosType ?? report.eidosSummary.eidosType;
    if (eidosTypeName == null || eidosTypeName.isEmpty) {
      eidosTypeName = 'The Radiant Creator';
    }

    // Get eidos type info from service
    final imageGroup =
        EidosGroupService.getImageGroupFromEidosType(eidosTypeName);
    final displayName = EidosGroupService.getGroupDisplayName(imageGroup);

    // Generate image URL using seed from eidos type name
    final seed = eidosTypeName.hashCode;
    final imageUrl = _generateImageUrl(imageGroup, seed);

    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: GroupBackgroundImage(
            imageUrl: imageUrl,
            displayGroupName: displayName,
          ),
        ),

        // Overlay gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Group info overlay
        Positioned(
          bottom: 120,
          left: 24,
          right: 24,
          child: GroupInfoOverlay(
            eidosTypeName: eidosTypeName,
            report: report,
            imageGroup: imageGroup,
          ),
        ),

        // Scroll hint
        if (onScrollHint != null)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: onScrollHint,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white70,
                    size: 32,
                  ),
                  Text(
                    'Swipe up for details',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Background image widget
class GroupBackgroundImage extends StatelessWidget {
  final String imageUrl;
  final String displayGroupName;

  const GroupBackgroundImage({
    super.key,
    required this.imageUrl,
    required this.displayGroupName,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return FallbackGroupBackground(
          displayGroupName: displayGroupName,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Eidos image error for $displayGroupName: $error');
        return FallbackGroupBackground(
          displayGroupName: displayGroupName,
        );
      },
    );
  }
}

// Fallback background when image fails to load
class FallbackGroupBackground extends StatelessWidget {
  final String displayGroupName;

  const FallbackGroupBackground({
    super.key,
    required this.displayGroupName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade400,
            Colors.red.shade600,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// Group information overlay
class GroupInfoOverlay extends StatelessWidget {
  final String eidosTypeName;
  final NarrativeReport report;
  final String imageGroup;

  const GroupInfoOverlay({
    super.key,
    required this.eidosTypeName,
    required this.report,
    required this.imageGroup,
  });

  @override
  Widget build(BuildContext context) {
    final eidosSummary = report.eidosSummary;

    // Use Enhanced API fields if available, otherwise fallback to service
    final groupTitle = eidosSummary.summaryTitle.isNotEmpty &&
            eidosSummary.summaryTitle != 'N/A'
        ? eidosSummary.summaryTitle
        : EidosGroupService.getGroupDisplayName(imageGroup);

    final actualDescription =
        eidosSummary.summaryText.isNotEmpty && eidosSummary.summaryText != 'N/A'
            ? eidosSummary.summaryText
            : EidosGroupService.getGroupDescription(imageGroup);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Group title
        Text(
          groupTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Eidos type name (clean version without unwanted text)
        Text(
          _cleanEidosTypeName(eidosTypeName),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            actualDescription,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),

        // Enhanced API: Personalized explanation (if available)
        if (eidosSummary.personalizedExplanation != null &&
            eidosSummary.personalizedExplanation!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why this group?',
                  style: TextStyle(
                    color: Colors.amber.shade200,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  eidosSummary.personalizedExplanation!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _cleanEidosTypeName(String eidosTypeName) {
    // Remove any unwanted prefixes or suffixes
    String cleaned = eidosTypeName;

    // Remove common unwanted patterns
    cleaned = cleaned.replaceAll(RegExp(r'^Eidos Report for\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^Report for\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+John Ferrari$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+for\s+\w+\s+\w+$'), '');

    return cleaned.trim();
  }
}

// Report content page
class ReportContentPage extends StatelessWidget {
  final NarrativeReport report;
  final VoidCallback onBackToGroup;

  const ReportContentPage({
    super.key,
    required this.report,
    required this.onBackToGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBackToGroup,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Your Analysis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                    _buildPersonalityProfile(
                        context, report.personalityProfile),
                    const SizedBox(height: 24),
                    _buildRelationshipInsight(
                        context, report.relationshipInsight),
                    const SizedBox(height: 24),
                    _buildCareerProfile(context, report.careerProfile),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEidosSummary(BuildContext context, EidosSummary summary) {
    return _buildSectionCard(
      context,
      title: summary.title == 'N/A' ? 'Eidos Summary' : summary.title,
      children: [
        _buildAttributeRow(context, 'Summary', summary.summaryText),
        _buildAttributeRow(
            context, 'Current Energy', summary.currentEnergyText),

        // Enhanced API fields
        if (summary.personalizedExplanation != null &&
            summary.personalizedExplanation!.isNotEmpty)
          _buildAttributeRow(context, 'Personalized Explanation',
              summary.personalizedExplanation!),

        if (summary.groupTraits != null && summary.groupTraits!.isNotEmpty)
          _buildTraitsList(context, 'Group Traits', summary.groupTraits!),

        if (summary.strengths != null && summary.strengths!.isNotEmpty)
          _buildTraitsList(context, 'Strengths', summary.strengths!),

        if (summary.growthAreas != null && summary.growthAreas!.isNotEmpty)
          _buildTraitsList(context, 'Growth Areas', summary.growthAreas!),

        if (summary.lifeGuidance != null && summary.lifeGuidance!.isNotEmpty)
          _buildAttributeRow(context, 'Life Guidance', summary.lifeGuidance!),
      ],
    );
  }

  Widget _buildInnateEidos(BuildContext context, InnateEidos innate) {
    return _buildSectionCard(
      context,
      title: innate.title == 'N/A' ? 'Innate Eidos' : innate.title,
      children: [
        _buildAttributeRow(
            context, innate.coreEnergyTitle, innate.coreEnergyText),
        _buildAttributeRow(context, innate.talentTitle, innate.talentText),
        _buildAttributeRow(context, innate.desireTitle, innate.desireText),
      ],
    );
  }

  Widget _buildJourney(BuildContext context, Journey journey) {
    return _buildSectionCard(
      context,
      title: journey.title == 'N/A' ? 'Journey' : journey.title,
      children: [
        _buildAttributeRow(context, journey.daeunTitle, journey.daeunText),
        _buildAttributeRow(
            context, journey.currentYearTitle, journey.currentYearText),
      ],
    );
  }

  Widget _buildTarotInsight(BuildContext context, TarotInsight insight) {
    return _buildSectionCard(
      context,
      title: insight.title == 'N/A' ? 'Tarot Insight' : insight.title,
      children: [
        _buildAttributeRow(context, insight.cardTitle, insight.cardMeaning),
        _buildAttributeRow(
            context, insight.cardMessageTitle, insight.cardMessageText),
      ],
    );
  }

  Widget _buildRyusWisdom(BuildContext context, RyusWisdom wisdom) {
    return _buildSectionCard(
      context,
      title: wisdom.title == 'N/A' ? 'Ryu\'s Wisdom' : wisdom.title,
      children: [
        _buildAttributeRow(context, 'Wisdom', wisdom.message),
      ],
    );
  }

  Widget _buildPersonalityProfile(
      BuildContext context, PersonalityProfile profile) {
    return _buildSectionCard(
      context,
      title: profile.title == 'N/A' ? 'Personality Profile' : profile.title,
      children: [
        _buildAttributeRow(context, 'Core Traits', profile.coreTraits),
        _buildAttributeRow(context, 'Likes', profile.likes),
        _buildAttributeRow(context, 'Dislikes', profile.dislikes),
        _buildAttributeRow(
            context, 'Relationship Style', profile.relationshipStyle),
        _buildAttributeRow(context, 'Inner Shadow', profile.shadow),
      ],
    );
  }

  Widget _buildRelationshipInsight(
      BuildContext context, RelationshipInsight insight) {
    return _buildSectionCard(
      context,
      title: insight.title == 'N/A' ? 'Relationship Insight' : insight.title,
      children: [
        _buildAttributeRow(context, 'Love Style', insight.loveStyle),
        _buildAttributeRow(context, 'Ideal Partner', insight.idealPartner),
        _buildAttributeRow(
            context, 'Relationship Advice', insight.relationshipAdvice),
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
            context, 'Success Strategy', profile.successStrategy),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitsList(
      BuildContext context, String title, List<String> traits) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...traits.map((trait) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        trait,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
