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

    // 🔍 DEBUG: 카드 데이터 설정 정보 출력
    print('🎯🎯🎯 === SETUP PAGE DATA DEBUG ===');
    print('🎯 Setting up card data...');
    print('🎯 Summary data:');
    print('   - currentEnergyText length: ${summary.currentEnergyText.length}');
    print(
        '   - personalizedExplanation length: ${summary.personalizedExplanation.length}');
    print('   - groupTraits count: ${summary.groupTraits.length}');
    print('   - strengths count: ${summary.strengths.length}');
    print('   - growthAreas count: ${summary.growthAreas.length}');
    print('   - lifeGuidance length: ${summary.lifeGuidance.length}');

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

    // 🔍 DEBUG: 생성된 카드 데이터 정보 출력
    print('🎯 Created ${cardDataList.length} cards:');
    for (int i = 0; i < cardDataList.length; i++) {
      final card = cardDataList[i];
      print(
          '   - Card $i: "${card['title']}" (desc: ${card['description']?.length ?? 0} chars)');
    }
    print('🎯🎯🎯 === END SETUP PAGE DATA DEBUG ===');

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

        // 🔍 DETAILED DEBUG: Print UI display data
        print('🖥️🖥️🖥️ === EIDOS GROUP SCREEN UI DEBUG ===');
        print('🖥️ EidosData Summary:');
        print('   - eidosType: "${eidosData.summary.eidosType}"');
        print('   - summaryTitle: "${eidosData.summary.summaryTitle}"');
        print('   - title: "${eidosData.summary.title}"');
        print('   - summaryText: "${eidosData.summary.summaryText}"');
        print('   - cardImageUrl: "${eidosData.summary.cardImageUrl}"');
        print('🖥️ Background Image URL: "${eidosData.backgroundImageUrl}"');
        print('🖥️ Card Image URLs:');
        eidosData.cardImageUrls.forEach((key, value) {
          print('   - $key: $value');
        });
        print('🖥️ Eidos Types in Group: ${eidosData.eidosTypesInGroup}');
        print('🖥️🖥️🖥️ === END UI DEBUG ===');

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
                          Builder(
                            builder: (context) {
                              print('📺📺📺 === SCREEN HEADER DEBUG ===');
                              print(
                                  '📺 Main Title (summaryTitle): "${eidosData.summary.summaryTitle}"');
                              print(
                                  '📺 Subtitle (eidosType): "${eidosData.summary.eidosType}"');
                              print('📺📺📺 === END SCREEN HEADER DEBUG ===');

                              return Column(
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
                                            blurRadius: 10.0,
                                            color: Colors.black)
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
                                        Shadow(
                                            blurRadius: 8.0,
                                            color: Colors.black)
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
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

                                // 🔍 DEBUG: 카드 전환 및 마지막 카드 확인
                                print('🎯🎯🎯 === CARD NAVIGATION DEBUG ===');
                                print('🎯 Current card index: $index');
                                print('🎯 Total cards: ${cardDataList.length}');
                                print(
                                    '🎯 Is last card: ${index == cardDataList.length - 1}');
                                print(
                                    '🎯 PageView height: $dynamicPageViewHeight');
                                print(
                                    '🎯🎯🎯 === END CARD NAVIGATION DEBUG ===');
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Your Unique Eidos Type',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  // 카드를 눌러도 슬라이드 상세 리포트로 이동
                                  try {
                                    // 기존에 저장된 상세 분석 데이터 확인
                                    final userAnalysisQuery = await _firestore
                                        .collection('users')
                                        .doc(_auth.currentUser?.uid)
                                        .collection('readings')
                                        .orderBy('timestamp', descending: true)
                                        .limit(1)
                                        .get();

                                    if (userAnalysisQuery.docs.isNotEmpty) {
                                      final latestReading =
                                          userAnalysisQuery.docs.first;
                                      final readingData = latestReading.data();

                                      // 리포트 데이터가 있는지 확인
                                      if (readingData.containsKey('report') &&
                                          readingData['report'] != null) {
                                        final reportData = readingData['report']
                                            as Map<String, dynamic>;

                                        // 그룹 분석 데이터만으로 간단한 NarrativeReport 생성
                                        final simplifiedReport =
                                            _createSimplifiedNarrativeReport(
                                                reportData);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SlideDetailedReportScreen(
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
                                        content: Text(
                                            'Error loading detailed report: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(100), // Pill shape
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.16),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Read more',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            size: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
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
    print('🎴🎴🎴 === _buildUniqueEidosTypeCard CALLED ===');
    print(
        '🎴 Method called with eidosData: ${eidosData != null ? 'NOT NULL' : 'NULL'}');

    final summary = eidosData.summary;
    print('🎴 Summary extracted: ${summary != null ? 'NOT NULL' : 'NULL'}');

    // 🔧 FIX: Use the correct image URL from summary.cardImageUrl
    final cardImageUrl =
        summary.cardImageUrl.isNotEmpty ? summary.cardImageUrl : '';
    print('🎴 Using summary.cardImageUrl: "$cardImageUrl"');
    print(
        '🎴 Original cardImageUrls lookup would have been: "${eidosData.cardImageUrls[summary.eidosType] ?? ''}"');
    print(
        '🎴 Available cardImageUrls keys: ${eidosData.cardImageUrls.keys.toList()}');

    // 🔍 DETAILED DEBUG: Print card display data
    print('🎴🎴🎴 === UNIQUE EIDOS TYPE CARD DEBUG ===');
    print('🎴 Card Title Logic:');
    print('   - summary.eidosType: "${summary.eidosType}"');
    print('   - summary.summaryTitle: "${summary.summaryTitle}"');
    print('   - Final title: "${summary.eidosType ?? summary.summaryTitle}"');
    print('🎴 Card Image URL: "$cardImageUrl"');
    print('🎴 Card Description Sources:');
    print('   - personalizedExplanation: "${summary.personalizedExplanation}"');
    print('   - classificationReason: "${summary.classificationReason}"');
    print('   - currentEnergyText: "${summary.currentEnergyText}"');
    print('   - summaryText: "${summary.summaryText}"');

    // 백엔드에서 상세한 설명 가져오기 (폴백 대신 실제 데이터 사용)
    String description = "Your unique essence is being revealed...";
    List<String> keywords = [];

    // 1. 개인화된 설명 우선 사용
    if (summary.personalizedExplanation.isNotEmpty &&
        summary.personalizedExplanation != 'N/A') {
      description = summary.personalizedExplanation;
      print('🎴 Using personalizedExplanation for description');
    }
    // 2. 분류 이유 사용
    else if (summary.classificationReason.isNotEmpty &&
        summary.classificationReason != 'N/A') {
      description = summary.classificationReason;
      print('🎴 Using classificationReason for description');
    }
    // 3. 핵심 정체성 설명 사용
    else if (summary.currentEnergyText.isNotEmpty &&
        summary.currentEnergyText != 'N/A') {
      description = summary.currentEnergyText;
      print('🎴 Using currentEnergyText for description');
    }
    // 4. 요약 텍스트 사용
    else if (summary.summaryText.isNotEmpty && summary.summaryText != 'N/A') {
      description = summary.summaryText;
      print('🎴 Using summaryText for description');
    }

    print('🎴 Final description: "$description"');

    // 백엔드에서 실제 키워드 가져오기
    if (summary.strengths.isNotEmpty) {
      keywords = summary.strengths.take(3).toList();
      print('🎴 Using strengths for keywords: $keywords');
    } else if (summary.groupTraits.isNotEmpty) {
      keywords = summary.groupTraits.take(3).toList();
      print('🎴 Using groupTraits for keywords: $keywords');
    }

    print('🎴🎴🎴 === CREATING UniqueEidosTypeCard WIDGET ===');
    print('🎴 About to create UniqueEidosTypeCard with:');
    print('🎴   - title: "${summary.eidosType ?? summary.summaryTitle}"');
    print('🎴   - imageUrl: "$cardImageUrl"');
    print('🎴   - description length: ${description.length}');
    print('🎴   - keywords count: ${keywords.length}');
    print('🎴🎴🎴 === END UNIQUE EIDOS TYPE CARD DEBUG ===');

    final cardWidget = UniqueEidosTypeCard(
      title: summary.eidosType ?? summary.summaryTitle,
      imageUrl: cardImageUrl,
      description: description,
      keywords: keywords,
      onTap: () async {
        print('🎴 UniqueEidosTypeCard onTap called!');
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

    print('🎴 UniqueEidosTypeCard widget created successfully, returning it');
    return cardWidget;
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

    return NarrativeReport(
      eidosSummary: EidosSummary(
        title: eidosSummary['title'] ?? 'Eidos Summary',
        summaryTitle: eidosSummary['group_name'] ?? 'Your Eidos Type',
        summaryText: eidosSummary['description'] ?? 'N/A',
        currentEnergyTitle: 'Current Energy',
        currentEnergyText: coreIdentitySection['text'] ?? 'N/A',
        eidosType: eidosSummary['eidos_type'],
        personalizedExplanation: eidosSummary['description'],
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
        title: 'Tarot Insight',
        cardTitle: 'Your Current Energy Card',
        cardMeaning: coreIdentitySection['text'] ?? 'N/A',
        cardMessageTitle: 'Message for You',
        cardMessageText: lifeGuidanceSection['text'] ?? 'N/A',
      ),
      ryusWisdom: RyusWisdom(
        title: 'Ryu\'s Wisdom',
        message: lifeGuidanceSection['text'] ??
            'Trust your unique essence and let it guide your path forward.',
      ),
      personalityProfile: PersonalityProfile(
        title: 'Personality Profile',
        coreTraits: strengthsSection['points']?.toString() ?? 'N/A',
        likes: 'Aligned with your eidos type characteristics',
        dislikes: 'Things that contradict your natural essence',
        relationshipStyle: 'Based on your core eidos nature',
        shadow: growthAreasSection['points']?.toString() ?? 'N/A',
      ),
      relationshipInsight: RelationshipInsight(
        title: 'Relationship Insight',
        loveStyle: 'Your love style reflects your eidos essence',
        idealPartner: 'Someone who appreciates your unique nature',
        relationshipAdvice: 'Be authentic to your true self in relationships',
      ),
      careerProfile: CareerProfile(
        title: 'Career Profile',
        aptitude: strengthsSection['points']?.toString() ?? 'N/A',
        workStyle: 'Aligned with your natural eidos characteristics',
        successStrategy:
            lifeGuidanceSection['text'] ?? 'Follow your authentic path',
      ),
      rawDataForDev: reportData,
      fiveElementsStrength: {},
      nameOhaengEnglish: {},
      eidosType: eidosSummary['eidos_type'],
    );
  }
}
