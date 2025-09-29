import 'package:flutter/material.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/utils/text_formatting_utils.dart';

class SlideDetailedReportScreen extends StatefulWidget {
  final NarrativeReport report;

  const SlideDetailedReportScreen({
    super.key,
    required this.report,
  });

  @override
  State<SlideDetailedReportScreen> createState() =>
      _SlideDetailedReportScreenState();
}

class _SlideDetailedReportScreenState extends State<SlideDetailedReportScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // Section titles and icons (English only)
  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Eidos Summary',
      'icon': Icons.auto_awesome,
      'subtitle': 'Your Core Essence',
    },
    {
      'title': 'Innate Nature',
      'icon': Icons.psychology,
      'subtitle': 'Born Characteristics',
    },
    {
      'title': 'Life Journey',
      'icon': Icons.timeline,
      'subtitle': 'Your Path Through Life',
    },
    {
      'title': 'Tarot Insight',
      'icon': Icons.style,
      'subtitle': 'Mystical Guidance',
    },
    {
      'title': 'Personality Profile',
      'icon': Icons.person,
      'subtitle': 'Character Traits',
    },
    {
      'title': 'Relationship Insight',
      'icon': Icons.favorite,
      'subtitle': 'Connection Wisdom',
    },
    {
      'title': 'Career Profile',
      'icon': Icons.work,
      'subtitle': 'Professional Path',
    },
    {
      'title': 'Ryu\'s Wisdom',
      'icon': Icons.lightbulb,
      'subtitle': 'Ancient Knowledge',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _sections.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF242424), Color(0xFF5E605F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '${_currentPage + 1} of ${_sections.length}',
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 상단 여백 (앱바 높이 고려)
            const SizedBox(height: 100),

            // 진행 상황 표시 (홈 화면 스타일로 개선)
            _buildProgressIndicator(),

            // 메인 콘텐츠
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  return _buildSectionPage(index);
                },
              ),
            ),

            // 네비게이션 버튼 (홈 화면 스타일로 개선)
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_sections.length, (index) {
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionPage(int index) {
    final section = _sections[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더 (박스 없이 깔끔하게)
          Row(
            children: [
              Icon(
                section['icon'],
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section['subtitle'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 섹션 콘텐츠 (박스 없이 직접 표시)
          _buildSectionContent(index),
        ],
      ),
    );
  }

  Widget _buildSectionContent(int index) {
    switch (index) {
      case 0: // Eidos Summary
        return _buildEidosSummaryContent();
      case 1: // Innate Nature
        return _buildSectionTextContent(
          widget.report.innateEidos.coreEnergyText.isNotEmpty &&
                  widget.report.innateEidos.coreEnergyText != 'N/A'
              ? "${widget.report.innateEidos.coreEnergyText}\n\nTalent: ${widget.report.innateEidos.talentText}\n\nInner Desire: ${widget.report.innateEidos.desireText}"
              : "Your innate nature reveals the core essence of who you are.",
        );
      case 2: // Life Journey
        return _buildSectionTextContent(
          widget.report.journey.daeunText.isNotEmpty &&
                  widget.report.journey.daeunText != 'N/A'
              ? "${widget.report.journey.daeunText}\n\nCurrent Year: ${widget.report.journey.currentYearText}"
              : "Your life journey unfolds with unique patterns and meaningful experiences.",
        );
      case 3: // Tarot Insight
        return _buildTarotInsightContent();
      case 4: // Personality Profile
        return _buildPersonalityProfileContent();
      case 5: // Relationship Insight
        return _buildRelationshipInsightContent();
      case 6: // Career Profile
        return _buildCareerProfileContent();
      case 7: // Ryu's Wisdom
        return _buildSectionTextContent(
          widget.report.ryusWisdom.message.isNotEmpty &&
                  widget.report.ryusWisdom.message != 'N/A'
              ? widget.report.ryusWisdom.message
              : "Ancient wisdom guides your path toward fulfillment and growth.",
        );
      default:
        return _buildSectionTextContent("Content coming soon...");
    }
  }

  Widget _buildEidosSummaryContent() {
    final summary = widget.report.eidosSummary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.title.isNotEmpty && summary.title != 'N/A') ...[
          Text(
            summary.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextFormattingUtils.buildFormattedText(
          summary.summaryText.isNotEmpty && summary.summaryText != 'N/A'
              ? summary.summaryText
              : "Your unique Eidos essence defines your core spiritual energy and life purpose.",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.6,
          ),
        ),
        if (summary.strengths != null && summary.strengths!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            "Key Strengths",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...summary.strengths!.map((trait) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: TextFormattingUtils.buildFormattedText(
                        trait,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildTarotInsightContent() {
    final tarotInsight = widget.report.tarotInsight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tarotInsight.cardTitle.isNotEmpty &&
            tarotInsight.cardTitle != 'N/A') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tarotInsight.cardTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextFormattingUtils.buildFormattedText(
          tarotInsight.cardMessageText.isNotEmpty &&
                  tarotInsight.cardMessageText != 'N/A'
              ? tarotInsight.cardMessageText
              : "The cards reveal important insights about your current path and future possibilities.",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildCareerProfileContent() {
    final careerProfile = widget.report.careerProfile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (careerProfile.aptitude.isNotEmpty &&
            careerProfile.aptitude != 'N/A') ...[
          const Text(
            "Career Aptitude",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            careerProfile.aptitude,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (careerProfile.workStyle.isNotEmpty &&
            careerProfile.workStyle != 'N/A') ...[
          const Text(
            "Work Style",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            careerProfile.workStyle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (careerProfile.successStrategy.isNotEmpty &&
            careerProfile.successStrategy != 'N/A') ...[
          const Text(
            "Success Strategy",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            careerProfile.successStrategy,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPersonalityProfileContent() {
    final profile = widget.report.personalityProfile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile.coreTraits.isNotEmpty && profile.coreTraits != 'N/A') ...[
          const Text(
            "Core Traits",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            profile.coreTraits,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (profile.likes.isNotEmpty && profile.likes != 'N/A') ...[
          const Text(
            "Likes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            profile.likes,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (profile.relationshipStyle.isNotEmpty &&
            profile.relationshipStyle != 'N/A') ...[
          const Text(
            "Relationship Style",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            profile.relationshipStyle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRelationshipInsightContent() {
    final insight = widget.report.relationshipInsight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (insight.loveStyle.isNotEmpty && insight.loveStyle != 'N/A') ...[
          const Text(
            "Love Style",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            insight.loveStyle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (insight.idealPartner.isNotEmpty &&
            insight.idealPartner != 'N/A') ...[
          const Text(
            "Ideal Partner",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            insight.idealPartner,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (insight.relationshipAdvice.isNotEmpty &&
            insight.relationshipAdvice != 'N/A') ...[
          const Text(
            "Relationship Advice",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormattingUtils.buildFormattedText(
            insight.relationshipAdvice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTextContent(String text) {
    return TextFormattingUtils.buildFormattedText(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        height: 1.6,
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        children: [
          // 이전 버튼
          if (_currentPage > 0)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withAlpha(77),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 다음/완료 버튼
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: _currentPage > 0 ? 8 : 0),
              child: ElevatedButton(
                onPressed: _currentPage < _sections.length - 1
                    ? _nextPage
                    : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentPage < _sections.length - 1) ...[
                      const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ] else ...[
                      const Icon(Icons.check, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
