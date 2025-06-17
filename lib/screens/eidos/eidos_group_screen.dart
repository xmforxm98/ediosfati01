import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:innerfive/services/eidos_group_service.dart';
import 'package:innerfive/widgets/eidos/info_card.dart';
import 'package:innerfive/widgets/eidos/eidos_type_card.dart';
import 'package:innerfive/screens/report/detailed_report_screen.dart';
import 'package:innerfive/widgets/eidos/unique_eidos_type_card.dart';

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
        'description': summary.summaryText,
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
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
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
                          Text(
                            eidosData.summary.summaryTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              shadows: [
                                Shadow(blurRadius: 10.0, color: Colors.black)
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
                    child: SizedBox(
                      height: 520,
                      child: Column(
                        children: [
                          _buildTabSelector(),
                          Expanded(
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
                                return InfoCard(
                                  title: cardData['title'],
                                  description: cardData['description'],
                                  imageUrl: cardData['imageUrl'],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailedReportScreen(
                                        detailedReport:
                                            eidosData.detailedReport,
                                      ),
                                    ),
                                  );
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
                          UniqueEidosTypeCard(
                            imageUrl: eidosData.summary.cardImageUrl,
                            eidosType: eidosData.summary.eidosType,
                            description: eidosData.summary.summaryText,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedReportScreen(
                                    detailedReport: eidosData.detailedReport,
                                  ),
                                ),
                              );
                            },
                          ),
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
                  )
                ],
              ),
            ),
          ],
        );
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
}
