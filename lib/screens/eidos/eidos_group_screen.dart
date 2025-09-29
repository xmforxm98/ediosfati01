import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innerfive/services/eidos_group_service.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/widgets/eidos/info_card.dart';
import 'package:innerfive/widgets/eidos/eidos_type_card.dart';
import 'package:innerfive/screens/report/detailed_report_screen.dart';
import 'package:innerfive/screens/report/slide_detailed_report_screen.dart';
import 'package:innerfive/widgets/eidos/unique_eidos_type_card.dart';
import 'package:innerfive/screens/eidos_analysis_screen.dart';

class EidosGroupScreen extends StatefulWidget {
  const EidosGroupScreen({super.key});

  @override
  State<EidosGroupScreen> createState() => _EidosGroupScreenState();
}

class _EidosGroupScreenState extends State<EidosGroupScreen> {
  late final Future<EidosGroupData?> eidosGroupDataFuture;
  final ScrollController scrollController = ScrollController();
  double imageOpacity = 1.0;

  PageController? pageController;
  int selectedCardIndex = 0;
  List<Map<String, dynamic>> cardDataList = [];

  // Firebase 인스턴스들
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  final Map<String, IconData> cardIcons = {
    'Core Identity': Icons.person_search,
    'Why You Belong to This Group': Icons.group_work,
    'Key Traits': Icons.star_border_purple500,
    'Your Strengths': Icons.thumb_up_alt,
    'Areas for Growth': Icons.trending_up,
    'Life Guidance': Icons.lightbulb,
  };

  void onScroll() {
    const double fadeEnd = 300.0;
    final double offset = scrollController.offset;
    final double newOpacity = (1.0 - (offset / fadeEnd)).clamp(0.0, 1.0);

    if (newOpacity != imageOpacity) {
      setState(() {
        imageOpacity = newOpacity;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    eidosGroupDataFuture = EidosGroupService().getEidosGroupData();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    pageController?.dispose();
    super.dispose();
  }

  void setupPageData(EidosGroupData eidosData) {
    if (cardDataList.isNotEmpty) return;

    final summary = eidosData.summary;
    final cardImageUrls = eidosData.cardImageUrls;

    cardDataList = [
      {
        'title': 'Core Identity',
        'description': summary.currentEnergyText,
        'imageUrl': cardImageUrls['Core Identity'],
      },
      {
        'title': 'Why You Belong to This Group',
        'description': summary.personalizedExplanation,
        'imageUrl': cardImageUrls['Why You Belong to This Group'],
      },
      {
        'title': 'Key Traits',
        'description': summary.groupTraits.map((e) => '• $e').join('\n'),
        'imageUrl': cardImageUrls['Key Traits'],
      },
      {
        'title': 'Your Strengths',
        'description': summary.strengths.map((e) => '• $e').join('\n'),
        'imageUrl': cardImageUrls['Your Strengths'],
      },
      {
        'title': 'Areas for Growth',
        'description': summary.growthAreas.map((e) => '• $e').join('\n'),
        'imageUrl': cardImageUrls['Areas for Growth'],
      },
      {
        'title': 'Life Guidance',
        'description': summary.lifeGuidance,
        'imageUrl': cardImageUrls['Life Guidance'],
      },
    ];

    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EidosGroupData?>(
      future: eidosGroupDataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('❌ EidosGroupScreen Error: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'An error occurred: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ EidosGroupScreen: Loading data...');
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          print('❌ EidosGroupScreen: No data available');
          return const Center(
            child: Text(
              'Failed to load data. No data available.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final eidosData = snapshot.data!;

        setupPageData(eidosData);

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF242424), Color(0xFF5E605F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Opacity(
              opacity: imageOpacity,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(eidosData.backgroundImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.8],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: CustomScrollView(
                controller: scrollController,
                slivers: [
                  const SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    title: Text(
                      'Inner Compass',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          MediaQuery.of(context).padding.top,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(flex: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eidosData.summary.summaryTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 10.0, color: Colors.black)
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                eidosData.summary.eidosType,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  shadows: [
                                    Shadow(blurRadius: 8.0, color: Colors.black)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(flex: 1),
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  'Scroll to explore your inner world',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                SizedBox(height: 8),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white70, size: 28),
                              ],
                            ),
                          ),
                          const SizedBox(
                              height: 112), // Bottom nav bar (88) + 24px margin
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildTabSelector(),
                        const SizedBox(height: 16),
                        // 🔧 FIX: 고정 높이를 완전히 제거하고 카드 내용에 맞춰 flexible하게 조정
                        Builder(builder: (context) {
                          final screenSize = MediaQuery.of(context).size;
                          final availableHeight = screenSize.height;
                          final safeAreaTop =
                              MediaQuery.of(context).padding.top;
                          final safeAreaBottom =
                              MediaQuery.of(context).padding.bottom;

                          // 동적 높이 계산 - 탭 선택기(~60px), 여백(40px), SafeArea 고려
                          const tabSelectorHeight = 60.0;
                          const spacing = 40.0; // 16px + 24px
                          final dynamicPageViewHeight = availableHeight -
                              safeAreaTop -
                              safeAreaBottom -
                              tabSelectorHeight -
                              spacing;

                          return SizedBox(
                            height: dynamicPageViewHeight,
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: cardDataList.length,
                              onPageChanged: (index) {
                                setState(() {
                                  selectedCardIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final cardData = cardDataList[index];
                                final isLastCard =
                                    index == cardDataList.length - 1;

                                return SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        isLastCard ? 40 : 20, // 마지막 카드에 추가 여백
                                  ),
                                  child: InfoCard(
                                    title: cardData['title'],
                                    description: cardData['description'],
                                    imageUrl: cardData['imageUrl'],
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  // Header section with padding
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            'Your Unique Eidos Type',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildUniqueEidosTypeCard(eidosData),
                          const SizedBox(height: 48), // 카드와 하단 네비게이션 바 사이의 간격
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 64.0),
                      child: Text(
                        'eidos fati',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUniqueEidosTypeCard(EidosGroupData eidosData) {
    final summary = eidosData.summary;

    // Use the correct image URL from summary.cardImageUrl
    final cardImageUrl =
        summary.cardImageUrl.isNotEmpty ? summary.cardImageUrl : '';

    // 백엔드에서 상세한 설명 가져오기
    String description = "Your unique essence is being revealed...";
    List<String> keywords = [];

    // 1. 개인화된 설명 우선 사용
    if (summary.personalizedExplanation.isNotEmpty &&
        summary.personalizedExplanation != 'N/A') {
      description = summary.personalizedExplanation;
    }
    // 2. 분류 이유 사용
    else if (summary.classificationReason.isNotEmpty &&
        summary.classificationReason != 'N/A') {
      description = summary.classificationReason;
    }
    // 3. 핵심 정체성 설명 사용
    else if (summary.currentEnergyText.isNotEmpty &&
        summary.currentEnergyText != 'N/A') {
      description = summary.currentEnergyText;
    }
    // 4. 요약 텍스트 사용
    else if (summary.summaryText.isNotEmpty && summary.summaryText != 'N/A') {
      description = summary.summaryText;
    }

    // 백엔드에서 실제 키워드 가져오기
    if (summary.strengths.isNotEmpty) {
      keywords = summary.strengths.take(3).toList();
    } else if (summary.groupTraits.isNotEmpty) {
      keywords = summary.groupTraits.take(3).toList();
    }

    return UniqueEidosTypeCard(
      title: summary.eidosType ?? summary.summaryTitle, // 개인 타입 우선 사용
      imageUrl: cardImageUrl,
      description: description,
      keywords: keywords,
      onTap: () async {
        // 기존에 저장된 상세 분석 데이터 확인
        try {
          final userAnalysisQuery = await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('readings')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (userAnalysisQuery.docs.isNotEmpty) {
            final latestReading = userAnalysisQuery.docs.first;
            final readingData = latestReading.data();

            // 리포트 데이터가 있는지 확인
            if (readingData.containsKey('report') &&
                readingData['report'] != null) {
              final reportData = readingData['report'] as Map<String, dynamic>;

              // 그룹 분석 데이터만으로 간단한 NarrativeReport 생성
              final simplifiedReport =
                  _createSimplifiedNarrativeReport(reportData);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SlideDetailedReportScreen(
                    report: simplifiedReport,
                  ),
                ),
              );
              return;
            }
          }

          // 상세 데이터가 없으면 안내 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Please generate a detailed analysis from the home screen first.'),
              backgroundColor: Colors.orange,
            ),
          );
        } catch (e) {
          print('Error loading detailed report: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading detailed report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(cardDataList.length, (index) {
            final cardData = cardDataList[index];
            final title = cardData['title'];
            final isSelected = selectedCardIndex == index;
            final iconColor = isSelected ? Colors.white : Colors.grey[600];
            final textColor = isSelected ? Colors.white : Colors.grey[600];

            return GestureDetector(
              onTap: () {
                pageController?.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cardIcons[title], color: iconColor, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      title.split(' ').first, // Show first word of title
                      style: TextStyle(color: textColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 그룹 분석 데이터로 간단한 NarrativeReport 생성
  NarrativeReport _createSimplifiedNarrativeReport(
      Map<String, dynamic> reportData) {
    // 개인화된 소개 섹션 확인
    final personalizedIntro =
        reportData['personalized_introduction'] as Map<String, dynamic>? ?? {};

    // 개인 타입 추출 (개인화된 소개에서)
    String? individualEidosType;
    if (personalizedIntro.containsKey('opening')) {
      final openingText = personalizedIntro['opening'] as String;
      final match = RegExp(r'As a (The [^,]+),').firstMatch(openingText);
      if (match != null) {
        individualEidosType = match.group(1);
      }
    }

    // 그룹 분석 데이터에서 필요한 정보 추출
    final eidosSummary =
        reportData['eidos_summary'] as Map<String, dynamic>? ?? {};
    final classificationReasoning =
        reportData['classification_reasoning'] as Map<String, dynamic>? ?? {};
    final coreIdentitySection =
        reportData['core_identity_section'] as Map<String, dynamic>? ?? {};
    final strengthsSection =
        reportData['strengths_section'] as Map<String, dynamic>? ?? {};
    final growthAreasSection =
        reportData['growth_areas_section'] as Map<String, dynamic>? ?? {};
    final lifeGuidanceSection =
        reportData['life_guidance_section'] as Map<String, dynamic>? ?? {};
    final traitsSection =
        reportData['traits_section'] as Map<String, dynamic>? ?? {};

    // 타로 인사이트 섹션도 확인
    final tarotInsight =
        reportData['tarot_insight'] as Map<String, dynamic>? ?? {};

    // 관계 인사이트 섹션 확인
    final relationshipInsight =
        reportData['relationship_insight'] as Map<String, dynamic>? ?? {};

    // 백엔드에서 새로 배포된 프로필 섹션들
    final personalityProfile =
        reportData['personality_profile'] as Map<String, dynamic>? ?? {};
    final careerProfile =
        reportData['career_profile'] as Map<String, dynamic>? ?? {};

    return NarrativeReport(
      eidosSummary: EidosSummary(
        title: personalizedIntro['title'] ?? 'Your Unique Essence',
        summaryTitle: individualEidosType ??
            eidosSummary['group_name'] ??
            'Your Eidos Type',
        summaryText: personalizedIntro['opening'] ??
            eidosSummary['description'] ??
            'N/A',
        currentEnergyTitle: 'Current Energy',
        currentEnergyText: coreIdentitySection['text'] ?? 'N/A',
        eidosType: individualEidosType ?? eidosSummary['eidos_type'],
        personalizedExplanation:
            personalizedIntro['opening'] ?? eidosSummary['description'],
        groupTraits: eidosSummary['key_traits'] is List
            ? (eidosSummary['key_traits'] as List)
                .map((e) => e.toString())
                .toList()
            : null,
        strengths: [strengthsSection['points']?.toString() ?? 'N/A'],
        growthAreas: [growthAreasSection['points']?.toString() ?? 'N/A'],
        lifeGuidance: lifeGuidanceSection['text'],
        classificationReason: classificationReasoning['text'],
        groupId: reportData['eidos_group_id'],
      ),
      innateEidos: InnateEidos(
        title: 'Innate Nature',
        coreEnergyTitle: 'Core Energy',
        coreEnergyText: coreIdentitySection['text'] ?? 'N/A',
        talentTitle: 'Natural Talents',
        talentText: strengthsSection['points']?.toString() ?? 'N/A',
        desireTitle: 'Inner Desires',
        desireText:
            'Based on your cosmic blueprint, your desires align with your eidos type.',
      ),
      journey: Journey(
        title: 'Life Journey',
        daeunTitle: 'Life Path',
        daeunText: classificationReasoning['text'] ?? 'N/A',
        currentYearTitle: 'Current Phase',
        currentYearText:
            'You are in a phase of understanding your true nature and potential.',
      ),
      tarotInsight: TarotInsight(
        title: tarotInsight['title'] ?? 'Tarot Insight',
        cardTitle:
            tarotInsight['card_name_display'] ?? 'Your Current Energy Card',
        cardMeaning: tarotInsight['card_meaning'] ??
            coreIdentitySection['text'] ??
            'N/A',
        cardMessageTitle: 'Message for You',
        cardMessageText: tarotInsight['card_message_text'] ??
            lifeGuidanceSection['text'] ??
            'N/A',
      ),
      ryusWisdom: RyusWisdom(
        title: 'Ryu\'s Wisdom',
        message: lifeGuidanceSection['text'] ??
            'Trust your unique essence and let it guide your path forward.',
      ),
      personalityProfile: PersonalityProfile(
        title: personalityProfile['title'] ?? 'Personality Profile',
        coreTraits: personalityProfile['coreTraits'] ??
            (coreIdentitySection['text'] ?? 'N/A'),
        likes: personalityProfile['likes'] ??
            (strengthsSection['full_text'] ??
                'Aligned with your eidos type characteristics'),
        dislikes: personalityProfile['dislikes'] ??
            'Things that contradict your natural essence',
        relationshipStyle: personalityProfile['relationshipStyle'] ??
            'Based on your core eidos nature',
        shadow: personalityProfile['shadow'] ??
            (growthAreasSection['full_text'] ?? 'N/A'),
      ),
      relationshipInsight: RelationshipInsight(
        title: relationshipInsight['title'] ?? 'Relationship Insight',
        loveStyle: relationshipInsight['love_style']?['full_text'] ??
            'Your love style reflects your eidos essence',
        idealPartner: relationshipInsight['ideal_partner']?['full_text'] ??
            'Someone who appreciates your unique nature',
        relationshipAdvice: relationshipInsight['relationship_advice']
                ?['full_text'] ??
            'Be authentic to your true self in relationships',
      ),
      careerProfile: CareerProfile(
        title: careerProfile['title'] ?? 'Career Profile',
        aptitude: careerProfile['aptitude'] ??
            (strengthsSection['full_text'] ??
                'Career paths that align with your eidos type'),
        workStyle: careerProfile['workStyle'] ??
            (coreIdentitySection['text'] ??
                'Work approach based on your core nature'),
        successStrategy: careerProfile['successStrategy'] ??
            (lifeGuidanceSection['text'] ??
                'Success strategies for your eidos type'),
      ),
      rawDataForDev: reportData,
      fiveElementsStrength: {},
      nameOhaengEnglish: {},
      eidosType: individualEidosType ?? eidosSummary['eidos_type'],
    );
  }
}
