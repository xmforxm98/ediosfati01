import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/models/daily_tarot.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/services/tarot_service.dart';
import 'package:innerfive/widgets/home/fortune_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaroScreen extends StatefulWidget {
  const TaroScreen({super.key});

  @override
  State<TaroScreen> createState() => _TaroScreenState();
}

class _TaroScreenState extends State<TaroScreen> {
  final PageController _pageController = PageController();
  List<Map<String, dynamic>>? _tarotDataList;
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  DailyTarot? _dailyTarot;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTarotData();
  }

  Future<void> _loadTarotData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = "Please log in to view your tarot reading.";
        _isLoading = false;
      });
      return;
    }

    try {
      final readingsQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('readings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (readingsQuery.docs.isNotEmpty) {
        final latestReadingData = readingsQuery.docs.first.data();
        final List<Map<String, dynamic>> tarotCards = [];

        if (latestReadingData.containsKey('report')) {
          final reportData =
              latestReadingData['report'] as Map<String, dynamic>;
          final report = NarrativeReport.fromJson(reportData);

          // Card 1: Eidos Tarot (from existing analysis)
          final tarotInsight = report.tarotInsight;

          // 실제 타로 카드 이름만 추출 (에이도스 타입 제거)
          String actualTarotCard = "The Fool";
          if (tarotInsight.cardTitle.isNotEmpty &&
              tarotInsight.cardTitle != 'N/A') {
            String cardTitle = tarotInsight.cardTitle;

            // "Card of Destiny: The Magician" 형태에서 타로 카드명만 추출
            if (cardTitle.contains(':')) {
              actualTarotCard = cardTitle.split(':').last.trim();
            } else if (cardTitle.contains('The ') &&
                !cardTitle.contains('Type') &&
                !cardTitle.contains('Mercenary')) {
              // "The Magician", "The Fool" 등 실제 타로 카드명만 사용
              actualTarotCard = cardTitle.trim();
            }
          }

          final cardInfo = TarotService.getCardInfo(actualTarotCard);

          // 백엔드에서 실제 타로 메시지 가져오기 (디버깅 추가)
          String tarotMessage =
              "Your tarot card reveals deep insights about your spiritual journey.";

          print('🎴 Tarot Message Debug:');
          print('   - cardMessageText: ${tarotInsight.cardMessageText}');
          print('   - cardMeaning: ${tarotInsight.cardMeaning}');
          print('   - actualTarotCard: $actualTarotCard');

          // 백엔드 메시지를 우선적으로 사용 (필터링 완화)
          if (tarotInsight.cardMessageText.isNotEmpty &&
              tarotInsight.cardMessageText != 'N/A') {
            // 에이도스 관련 내용이 포함되어 있어도 타로 관련 내용이 있으면 사용
            if (tarotInsight.cardMessageText.toLowerCase().contains('card') ||
                tarotInsight.cardMessageText.toLowerCase().contains('tarot') ||
                tarotInsight.cardMessageText
                    .toLowerCase()
                    .contains(actualTarotCard.toLowerCase()) ||
                tarotInsight.cardMessageText.length > 50) {
              // 충분히 긴 설명이면 사용
              tarotMessage = tarotInsight.cardMessageText;
              print('   - Using cardMessageText: $tarotMessage');
            }
          }

          // cardMessageText가 적절하지 않으면 cardMeaning 사용
          if (tarotMessage ==
                  "Your tarot card reveals deep insights about your spiritual journey." &&
              tarotInsight.cardMeaning.isNotEmpty &&
              tarotInsight.cardMeaning != 'N/A') {
            if (tarotInsight.cardMeaning.toLowerCase().contains('card') ||
                tarotInsight.cardMeaning.toLowerCase().contains('tarot') ||
                tarotInsight.cardMeaning
                    .toLowerCase()
                    .contains(actualTarotCard.toLowerCase()) ||
                tarotInsight.cardMeaning.length > 30) {
              tarotMessage = tarotInsight.cardMeaning;
              print('   - Using cardMeaning: $tarotMessage');
            }
          }

          print('   - Final tarotMessage: $tarotMessage');

          tarotCards.add({
            'type': 'Eidos Tarot',
            'title': actualTarotCard, // 실제 타로 카드명만 사용
            'subtitle': 'Your Personal Tarot Reading',
            'message': tarotMessage,
            'backgroundImageUrl': cardInfo['imageUrl'] ?? '',
          });

          // Card 2: Daily Tarot (from new API)
          try {
            // 분석 리포트에서 필요한 정보 추출
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              final userNickname =
                  userData['nickname'] ?? userData['displayName'] ?? 'User';

              // 리포트에서 life_path_number와 day_master 추출
              int? lifePathNumber;
              String? dayMaster;

              if (reportData.containsKey('life_path_number')) {
                lifePathNumber = reportData['life_path_number'] as int?;
              }
              if (reportData.containsKey('day_master')) {
                dayMaster = reportData['day_master'] as String?;
              }

              // 추출된 데이터로 사용자 프로필 구성 (영어 이름 강제)
              final userProfile = {
                'name': _convertToEnglishName(userNickname), // 영어 이름으로 변환
                'eidos_type': report.eidosSummary.eidosType ?? 'Unknown',
                'birth_date': userData['birthDate'] ??
                    '${userData['year']}-${userData['month']?.toString().padLeft(2, '0')}-${userData['day']?.toString().padLeft(2, '0')}',
                'birth_time':
                    userData['birthTime'] ?? '${userData['hour'] ?? 12}:00',
                'city': userData['city'],
                'gender': userData['gender'],
                'life_path_number': lifePathNumber,
                'day_master': dayMaster,
                'user_id': user.uid,
              };

              print('Loading daily tarot with user profile: $userProfile');
              final dailyTarot = await _apiService.getDailyTarot(userProfile);
              _dailyTarot = dailyTarot;
              print(
                  '✅ Daily Tarot loaded successfully: ${dailyTarot.cardNameDisplay}');

              tarotCards.add({
                'type': 'Daily Tarot',
                'title': dailyTarot.cardNameDisplay,
                'subtitle': 'Your Personalized Tarot for Today',
                'message': dailyTarot.message.content,
                'backgroundImageUrl': _getFirebaseImageUrl(
                    dailyTarot.cardImageUrl, dailyTarot.cardId),
                'dailyTarot': dailyTarot, // 전체 데이터 저장
              });
            }
          } catch (e) {
            print("Failed to load daily tarot: $e");
            // API 호출 실패 시 에러메시지를 담은 카드를 추가하여 사용자에게 피드백
            tarotCards.add({
              'type': 'Daily Tarot',
              'title': 'Error',
              'subtitle': 'Could not load Daily Tarot',
              'message':
                  'There was an error fetching your daily reading. Please try again later.\n\nDetails: $e',
              'backgroundImageUrl': '',
            });
          }
        }

        if (tarotCards.isNotEmpty) {
          _tarotDataList = tarotCards;
        } else {
          _errorMessage = "No report found in your latest reading.";
        }
      } else {
        _errorMessage = "Complete an analysis first to see your tarot reading.";
      }
    } catch (e, stackTrace) {
      _errorMessage = "An error occurred while loading data: $e";
      print('❌ Tarot loading error: $e');
      print('❌ Stack trace: $stackTrace');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 한글 이름을 영어 이름으로 변환하는 헬퍼 함수
  String _convertToEnglishName(String name) {
    // 간단한 변환 로직 - 실제로는 더 정교한 변환이 필요할 수 있음
    final Map<String, String> nameMap = {
      'Sage': 'Sage',
      'Alex': 'Alex',
      'Jordan': 'Jordan',
      'Casey': 'Casey',
      'Taylor': 'Taylor',
      '세이지': 'Sage',
      '알렉스': 'Alex',
      '조던': 'Jordan',
      // 더 많은 매핑 추가 가능
    };

    // 이미 영어면 그대로 반환
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return name;
    }

    // 매핑이 있으면 변환
    if (nameMap.containsKey(name)) {
      return nameMap[name]!;
    }

    // 기본값
    return 'Seeker';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadTarotData,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    if (_tarotDataList == null || _tarotDataList!.isEmpty) {
      return const Center(
          child: Text('No tarot card to display.',
              style: TextStyle(color: Colors.white70)));
    }

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Tarot Guidance',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          scrolledUnderElevation: 0,
          floating: false,
          snap: false,
          pinned: false,
          automaticallyImplyLeading: false,
        ),
        SliverToBoxAdapter(
          child: _buildTabBar(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _tarotDataList!.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final tarot = _tarotDataList![index];

                // Daily Tarot 카드인 경우 새로운 UI 사용
                if (tarot['type'] == 'Daily Tarot' &&
                    tarot.containsKey('dailyTarot')) {
                  return _buildDailyTarotCard(
                      tarot['dailyTarot'] as DailyTarot);
                }

                // Eidos Tarot 카드는 기존 FortuneCard 사용
                return _buildEidosTarotCard(tarot);
              },
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
    );
  }

  Widget _buildTabBar() {
    if (_tarotDataList == null || _tarotDataList!.length <= 1) {
      return const SizedBox(height: 24);
    }

    final List<Map<String, dynamic>> tabsInfo = _tarotDataList!.map((data) {
      String type = data['type'] as String? ?? '';
      if (type == 'Eidos Tarot') {
        return {'name': 'Your Tarot'};
      } else if (type == 'Daily Tarot') {
        return {'name': 'Today\'s Tarot'};
      } else {
        return {'name': 'Tarot'};
      }
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(tabsInfo.length, (index) {
          final isSelected = _selectedIndex == index;
          final tabInfo = tabsInfo[index];
          final color = isSelected ? Colors.white : Colors.grey[600];

          return GestureDetector(
            onTap: () {
              if (_selectedIndex != index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Text(
                tabInfo['name'] as String,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEidosTarotCard(Map<String, dynamic> tarot) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: FortuneCard(
        isLoading: false,
        fortuneData: {
          'title': tarot['title'],
          'subtitle': tarot['subtitle'],
          'message': tarot['message'],
        },
        fortuneType: tarot['type'],
        backgroundImageUrl: tarot['backgroundImageUrl'],
      ),
    )
        .animate()
        .scaleXY(end: 1, duration: 500.ms, curve: Curves.easeOutCubic)
        .fadeIn();
  }

  Widget _buildDailyTarotCard(DailyTarot dailyTarot) {
    final themeColor = _getThemeColor(dailyTarot.message.illustrationCue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 카드 이미지와 기본 정보
            _buildCardHeader(dailyTarot, themeColor),
            const SizedBox(height: 24),

            // 메인 메시지
            _buildMainMessage(dailyTarot, themeColor),
            const SizedBox(height: 24),

            // 섹션들
            _buildSections(dailyTarot),
            const SizedBox(height: 24),

            // Action Cards
            _buildActionCards(dailyTarot),
            const SizedBox(height: 24),

            // 명언과 해시태그
            _buildWisdomAndHashtags(dailyTarot, themeColor),
          ],
        ),
      ),
    )
        .animate()
        .slideY(duration: 600.ms, begin: 0.3, curve: Curves.easeOutCubic)
        .fadeIn();
  }

  Widget _buildCardHeader(DailyTarot dailyTarot, Color themeColor) {
    final imageUrl =
        _getFirebaseImageUrl(dailyTarot.cardImageUrl, dailyTarot.cardId);
    print('🎴 Daily Tarot image URL: ${dailyTarot.cardImageUrl}');
    print('🎴 Daily Tarot card ID: ${dailyTarot.cardId}');
    print('🎴 Final image URL: $imageUrl');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // 카드 이미지
          Container(
            height: 200,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: themeColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Image loading error: $error');
                        return Container(
                          color: Colors.grey[800],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported,
                                  color: Colors.white54, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Image failed to load',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: Colors.white54, size: 48),
                          SizedBox(height: 8),
                          Text(
                            'No image URL',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // 카드 이름
          Text(
            dailyTarot.cardNameDisplay,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // 테마 키워드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dailyTarot.themeKeyword,
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMessage(DailyTarot dailyTarot, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dailyTarot.message.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dailyTarot.message.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSections(DailyTarot dailyTarot) {
    return Column(
      children: dailyTarot.message.sections.map((section) {
        // Action Cards는 별도로 처리하므로 여기서 제외
        if (section.sectionKey == 'daily_actions' ||
            section.sectionKey == 'daily_cautions') {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionCards(DailyTarot dailyTarot) {
    final sections = dailyTarot.message.sections;
    final actionsSection = sections.firstWhere(
      (s) => s.sectionKey == 'daily_actions',
      orElse: () => DailyTarotSection(
        title: 'Recommended Actions',
        content: '',
        points: [],
        fullText: '',
        sectionKey: 'daily_actions',
      ),
    );

    final cautionsSection = sections.firstWhere(
      (s) => s.sectionKey == 'daily_cautions',
      orElse: () => DailyTarotSection(
        title: 'Things to Avoid',
        content: '',
        points: [],
        fullText: '',
        sectionKey: 'daily_cautions',
      ),
    );

    return Row(
      children: [
        // Do Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        actionsSection.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (actionsSection.hasPoints)
                  ...actionsSection.points.map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(color: Colors.green)),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                else if (actionsSection.hasContent)
                  Text(
                    actionsSection.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Don't Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.2),
                  Colors.orange.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cautionsSection.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (cautionsSection.hasPoints)
                  ...cautionsSection.points.map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(color: Colors.orange)),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                else if (cautionsSection.hasContent)
                  Text(
                    cautionsSection.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWisdomAndHashtags(DailyTarot dailyTarot, Color themeColor) {
    return Column(
      children: [
        // 명언
        if (dailyTarot.message.aphorism.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: themeColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.format_quote, color: Colors.white54, size: 32),
                const SizedBox(height: 12),
                Text(
                  dailyTarot.message.aphorism,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // 해시태그
        if (dailyTarot.message.hashtags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: dailyTarot.message.hashtags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Color _getThemeColor(String illustrationCue) {
    if (illustrationCue.contains('Crimson Red')) return const Color(0xFFDC143C);
    if (illustrationCue.contains('Mystic Teal')) return const Color(0xFF008B8B);
    if (illustrationCue.contains('Sage Green')) return const Color(0xFF87A96B);
    if (illustrationCue.contains('Golden Yellow'))
      return const Color(0xFFFFD700);
    if (illustrationCue.contains('Metallic Gold'))
      return const Color(0xFFD4AF37);
    if (illustrationCue.contains('Royal Purple'))
      return const Color(0xFF6A0DAD);
    if (illustrationCue.contains('Deep Blue')) return const Color(0xFF003366);
    if (illustrationCue.contains('Silver')) return const Color(0xFFC0C0C0);
    return const Color(0xFF4A90E2); // 기본 색상
  }

  String _getFirebaseImageUrl(String originalUrl, String cardId) {
    // 백엔드에서 받은 URL이 유효하면 그대로 사용
    if (originalUrl.isNotEmpty && originalUrl.startsWith('http')) {
      return originalUrl;
    }

    // 카드 ID를 TarotService 매핑에 맞게 변환
    String mappedCardId = _mapCardIdToTarotService(cardId);

    // TarotService를 통해 Firebase URL 생성
    try {
      final cardInfo = TarotService.getCardInfo(mappedCardId);
      print(
          '🎴 Tarot card mapping: $cardId -> $mappedCardId -> ${cardInfo['imageUrl']}');
      return cardInfo['imageUrl'] ?? '';
    } catch (e) {
      print('Error getting Firebase tarot image URL: $e');
      return '';
    }
  }

  /// 백엔드 카드 ID를 TarotService 매핑에 맞게 변환
  String _mapCardIdToTarotService(String cardId) {
    // 백엔드에서 오는 카드 ID를 TarotService의 키로 변환
    final cardIdMappings = {
      // 기본 형태
      'fool': 'foolcrown',
      'the_fool': 'foolcrown',
      'magician': 'magician',
      'the_magician': 'magician',
      'high_priestess': 'highpriestess',
      'the_high_priestess': 'highpriestess',
      'empress': 'theempress',
      'the_empress': 'theempress',
      'emperor': 'emperor',
      'the_emperor': 'emperor',
      'hierophant': 'hierophant',
      'the_hierophant': 'hierophant',
      'lovers': 'lover',
      'the_lovers': 'lover',
      'chariot': 'chariot',
      'the_chariot': 'chariot',
      'strength': 'strength',
      'hermit': 'hermit',
      'the_hermit': 'hermit',
      'wheel_of_fortune': 'wheeloffortune',
      'wheel': 'wheeloffortune',
      'justice': 'justice',
      'hanged_man': 'hangedman',
      'the_hanged_man': 'hangedman',
      'death': 'death',
      'temperance': 'temperance',
      'devil': 'devil',
      'the_devil': 'devil',
      'tower': 'tower',
      'the_tower': 'tower',
      'star': 'star',
      'the_star': 'star',
      'moon': 'moon',
      'the_moon': 'moon',
      'sun': 'sun',
      'the_sun': 'sun',
      'judgement': 'judgment',
      'judgment': 'judgment',
      'world': 'world',
      'the_world': 'world',

      // 추가 변형들
      'foolcrown': 'foolcrown',
      'highpriestess': 'highpriestess',
      'theempress': 'theempress',
      'lover': 'lover',
      'wheeloffortune': 'wheeloffortune',
      'hangedman': 'hangedman',
    };

    // 입력값 정규화
    String normalizedCardId =
        cardId.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_').trim();

    print('🎴 Normalizing card ID: "$cardId" -> "$normalizedCardId"');

    // 직접 매핑 확인
    if (cardIdMappings.containsKey(normalizedCardId)) {
      String mapped = cardIdMappings[normalizedCardId]!;
      print('🎴 Direct mapping found: "$normalizedCardId" -> "$mapped"');
      return mapped;
    }

    // 부분 매칭 시도
    for (final entry in cardIdMappings.entries) {
      if (normalizedCardId.contains(entry.key) ||
          entry.key.contains(normalizedCardId)) {
        print(
            '🎴 Partial mapping found: "$normalizedCardId" -> "${entry.value}"');
        return entry.value;
      }
    }

    // 매핑 실패시 기본값
    print(
        '🎴 No mapping found for: "$normalizedCardId", using default: foolcrown');
    return 'foolcrown';
  }

  // 🎴 홈 화면 FortuneCard와 동일한 스타일의 타로 카드
  Widget _buildTarotCardWithFortuneStyle(Map<String, dynamic> tarot) {
    // Daily Tarot인 경우 추가 정보 추출
    String title = tarot['title'] ?? 'Tarot Card';
    String subtitle = tarot['subtitle'] ?? 'Your Reading';
    String message = tarot['message'] ?? 'No message available';
    String backgroundImageUrl = tarot['backgroundImageUrl'] ?? '';

    // Daily Tarot 객체가 있는 경우 더 풍부한 정보 사용
    if (tarot.containsKey('dailyTarot')) {
      final dailyTarot = tarot['dailyTarot'] as DailyTarot;
      title = dailyTarot.cardNameDisplay;
      subtitle = dailyTarot.themeKeyword.isNotEmpty
          ? dailyTarot.themeKeyword
          : 'Your Personalized Tarot for Today';
      message = dailyTarot.message.content;
      backgroundImageUrl =
          _getFirebaseImageUrl(dailyTarot.cardImageUrl, dailyTarot.cardId);
    }

    return FractionallySizedBox(
      widthFactor: 0.9,
      child: FortuneCard(
        isLoading: false,
        fortuneData: {
          'title': title,
          'subtitle': subtitle,
          'message': message,
        },
        fortuneType: tarot['type'] ?? 'Tarot',
        backgroundImageUrl: backgroundImageUrl,
      ),
    )
        .animate()
        .scaleXY(end: 1, duration: 500.ms, curve: Curves.easeOutCubic)
        .fadeIn();
  }
}
