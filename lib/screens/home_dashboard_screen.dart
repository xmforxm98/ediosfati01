import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';
import 'package:innerfive/utils/ganzhi_utils.dart';
import 'package:innerfive/utils/eidos_hashtags.dart';
import 'package:innerfive/utils/daily_message_generator.dart';
import 'package:innerfive/utils/tag_image_manager.dart';
import 'daily_fortune_detail_screen.dart';
import 'package:innerfive/services/daily_fortune_service.dart';
import 'package:innerfive/services/fortune_background_service.dart';

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToReport;

  const HomeDashboardScreen({super.key, required this.onNavigateToReport});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  User? _user;
  String _userName = 'User';
  String _userNickname = 'User';
  Map<String, dynamic>? _latestUserInput;
  NarrativeReport? _latestReport;
  bool _isLoading = true;
  Map<String, List<String>> _eidosCardUrls = {};
  List<String> _currentEidosImageUrls = [];

  // New state variables for date data
  String _gregorianDate = '';
  String _lunarDate = '';
  String _ganzhiDate = '';
  String _ganzhiMeaning = '';

  // PageView를 위한 상태 변수 추가
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  String _selectedFortuneType = 'Love'; // 선택된 운세 타입
  Map<String, dynamic>? _currentFortuneData; // 현재 운세 데이터
  bool _isLoadingFortune = false; // 운세 로딩 상태
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadFortuneData(_selectedFortuneType); // 초기 운세 데이터 로드
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupImageCarousel() {
    if (_currentEidosImageUrls.isNotEmpty) {
      _timer?.cancel(); // 이전 타이머가 있다면 취소
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (_pageController.hasClients) {
          if (_currentPage < _currentEidosImageUrls.length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  Future<void> _loadAllData() async {
    _loadDateData(); // Load date data first
    // These can run in parallel
    await Future.wait([
      _loadEidosCardUrls(),
      _loadUserData(),
      TagImageManager.loadTagImageUrls(), // 태그 이미지 URL 로드
      FortuneBackgroundService.loadBackgroundUrls(), // 운세 배경 이미지 URL 로드
    ]);

    // 데이터 로드가 완료된 후 UI 업데이트
    if (mounted) {
      setState(() {
        _isLoading = false;
        _setupImageCarousel(); // 데이터 로드 후 캐러셀 설정
      });
    }
  }

  void _loadDateData() {
    final now = DateTime.now();
    final solar = Solar.fromDate(now);
    final lunar = solar.getLunar();
    final dayGanzhi = '${lunar.getDayGan()}${lunar.getDayZhi()}';

    setState(() {
      _gregorianDate = DateFormat('EEEE, MMMM d, yyyy', 'en_US').format(now);
      _lunarDate = 'Lunar ${lunar.getMonth()}.${lunar.getDay()}';
      _ganzhiDate = '$dayGanzhi Day';
      _ganzhiMeaning = GanzhiUtils.getGanzhiMeaning(dayGanzhi);
    });
  }

  Future<void> _loadEidosCardUrls() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/eidos_card_urls.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        _eidosCardUrls = data.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        );
      });
    } catch (e) {
      print("Error loading eidos_card_urls.json: $e");
    }
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      // Load user data from Firestore to get nickname
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = userData['displayName'] ?? _user?.displayName ?? 'User';
            _userNickname = userData['nickname'] ?? _userName;
          });
        } else {
          setState(() {
            _userName = _user?.displayName ?? 'User';
            _userNickname = _userName;
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        setState(() {
          _userName = _user?.displayName ?? 'User';
          _userNickname = _userName;
        });
      }

      // Fetch latest report from Firestore
      try {
        final readingsQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('readings')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (readingsQuery.docs.isNotEmpty) {
          final latestReadingData = readingsQuery.docs.first.data();
          if (latestReadingData.containsKey('report') &&
              latestReadingData.containsKey('userInput')) {
            _latestUserInput =
                latestReadingData['userInput'] as Map<String, dynamic>?;
            _latestReport = NarrativeReport.fromJson(
              latestReadingData['report'] as Map<String, dynamic>,
            );
            if (_latestReport != null) {
              _currentEidosImageUrls =
                  _eidosCardUrls[_latestReport!.eidosSummary.title] ?? [];
            }
          }
        }
      } catch (e) {
        print("Error loading latest report: $e");
      }
    }
  }

  Future<void> _loadFortuneData(String fortuneType) async {
    setState(() {
      _isLoadingFortune = true;
    });

    try {
      final fortuneService = DailyFortuneService();
      final data = await fortuneService.generateDailyFortune(
        fortuneType,
        _latestReport,
        _userNickname ?? 'User',
      );

      setState(() {
        _currentFortuneData = data;
        _isLoadingFortune = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFortune = false;
      });
      print('Error loading fortune data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            title: Image.asset(
              'assets/images/logo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            floating: false,
            snap: false,
            pinned: false,
            expandedHeight: 100,
            automaticallyImplyLeading: false,
          ),
          SliverToBoxAdapter(
            child: ScrollConfiguration(
              behavior: const NoScrollbarBehavior(),
              child: _isLoading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildTopHeader(),
                          const SizedBox(height: 24),
                          _buildSummaryCard(),
                          const SizedBox(height: 24),
                          _buildDailyFortuneSection(),
                          const SizedBox(height: 40),
                          _buildFooterText(),
                          const SizedBox(height: 140),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _gregorianDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _lunarDate,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _ganzhiDate,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '($_ganzhiMeaning)',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    String eidosTitle =
        _latestReport?.eidosSummary.title ?? "your unique Eidos";

    // Generate dynamic message using cosmic energy system
    final dayGanzhi = _ganzhiDate.replaceAll(' Day', '');
    print('🔍 Debug Info:');
    print('  - dayGanzhi: $dayGanzhi');
    print('  - eidosType: $eidosTitle');
    print('  - userName: $_userNickname');

    final dailyMessage = DailyMessageGenerator.generateMessage(
      userName: _userNickname,
      eidosType: eidosTitle,
      ganzhi: dayGanzhi,
    );

    print('  - Generated element: ${dailyMessage.cosmicElement}');
    print('  - Generated hashtags: ${dailyMessage.hashtags}');

    String todayMessage = dailyMessage.text;
    List<String> hashtags = dailyMessage.hashtags;

    // 해시태그에서 원소 이미지 URL 가져오기
    final tagImageUrl = TagImageManager.getImageUrlForHashtags(hashtags);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(
        minHeight: 600, // 최소 높이 설정으로 여유롭게
      ),
      decoration: BoxDecoration(
        color: Colors.black, // 카드 배경을 검은색으로 설정
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 배경 이미지 (전체 너비, 상단 부분만)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300, // 이미지 높이를 제한하여 상단 부분만 표시
              child: tagImageUrl != null
                  ? Image.network(
                      tagImageUrl,
                      width: double.infinity, // 100% 너비
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.withOpacity(0.8),
                                Colors.purple.withOpacity(0.8),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withOpacity(0.8),
                            Colors.purple.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
            ),
            // 일러스트 이미지 위의 그라데이션 레이어 (블랙 0% → 100%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300, // 이미지와 같은 높이
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // 위쪽 0% (투명)
                      Colors.black, // 아래쪽 100% 검은색
                    ],
                  ),
                ),
              ),
            ),
            // 컨텐츠
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 260), // 상단 여백 대폭 증가
                  // 메인 타이틀
                  Text(
                    "Today's Energy",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 메인 메시지 (모든 텍스트 표시)
                  Text(
                    todayMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 디테일한 메시지 (Ryu's Wisdom) - 모든 텍스트 표시
                  Text(
                    _latestReport?.ryusWisdom.message ??
                        "We're preparing your cosmic insights...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 해시태그
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: hashtags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24), // 하단 여백 줄임
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyFortuneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFortuneTabBar(),
        const SizedBox(height: 16),
        _buildFortuneCard(),
      ],
    );
  }

  Widget _buildFortuneTabBar() {
    final fortuneTypes = [
      {
        'title': 'Love',
        'icon_filled': Icons.favorite,
        'icon_outlined': Icons.favorite_outline
      },
      {
        'title': 'Career',
        'icon_filled': Icons.work,
        'icon_outlined': Icons.work_outline
      },
      {
        'title': 'Wealth',
        'icon_filled': Icons.attach_money,
        'icon_outlined': Icons.attach_money_outlined
      },
      {
        'title': 'Health',
        'icon_filled': Icons.local_hospital,
        'icon_outlined': Icons.local_hospital_outlined
      },
      {
        'title': 'Social',
        'icon_filled': Icons.people,
        'icon_outlined': Icons.people_outline
      },
      {
        'title': 'Growth',
        'icon_filled': Icons.trending_up,
        'icon_outlined': Icons.trending_up_outlined
      },
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: fortuneTypes.length,
        itemBuilder: (context, index) {
          final fortune = fortuneTypes[index];
          final isSelected = _selectedFortuneType == fortune['title'] as String;

          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _onFortuneTabSelected(fortune['title'] as String),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isSelected
                            ? fortune['icon_filled'] as IconData
                            : fortune['icon_outlined'] as IconData,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        size: isSelected ? 24 : 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fortune['title'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onFortuneTabSelected(String fortuneType) {
    if (_selectedFortuneType != fortuneType) {
      setState(() {
        _selectedFortuneType = fortuneType;
      });
      _loadFortuneData(fortuneType);
    }
  }

  Widget _buildFortuneCard() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final backgroundImageUrl =
        FortuneBackgroundService.getConsistentBackgroundUrl(
      _selectedFortuneType,
      _userNickname,
      today,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. Background Image
            if (backgroundImageUrl != null)
              Positioned.fill(
                child: Image.network(
                  backgroundImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Fortune card background failed to load: $error');
                    return Container(color: Colors.black);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  },
                ),
              )
            else
              Positioned.fill(child: Container(color: Colors.grey[900])),

            // 2. Loading Indicator (전체 카드 로딩)
            if (_isLoadingFortune)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

            // 3. Content Scrim (가독성을 위한 그라데이션)
            if (!_isLoadingFortune)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

            // 4. "Coming Soon" or Fortune Content
            if (!_isLoadingFortune)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _currentFortuneData == null
                    ? const AspectRatio(
                        aspectRatio: 3 / 4.5,
                        child: Center(
                          child: Text(
                            'Coming Soon',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 카드의 너비에 비례하는 상단 공간을 만들어 이미지가 보이게 함
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SizedBox(
                                height: constraints.maxWidth * 0.7,
                              );
                            },
                          ),
                          // 카테고리 제목
                          Row(
                            children: [
                              Icon(
                                _getFortuneIcon(_selectedFortuneType),
                                color: Colors.white.withOpacity(0.9),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getFortuneTitle(_selectedFortuneType),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 운세 제목
                          Text(
                            _currentFortuneData!['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 운세 부제목
                          Text(
                            _currentFortuneData!['subtitle'] ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 구분선
                          Container(
                            height: 1,
                            width: 50,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),

                          // 운세 메시지 (전체)
                          Text(
                            _currentFortuneData!['message'] as String? ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }

  String _getFortuneTitle(String fortuneType) {
    switch (fortuneType) {
      case 'Love':
        return 'Love & Connections';
      case 'Career':
        return 'Work & Purpose';
      case 'Wealth':
        return 'Money & Abundance';
      case 'Health':
        return 'Wellness & Vitality';
      case 'Social':
        return 'Relationships & Community';
      case 'Growth':
        return 'Learning & Evolution';
      case 'Advice':
        return 'Today\'s Guidance';
      default:
        return 'Your Daily Insight';
    }
  }

  String _getFortuneSubtitle(String fortuneType) {
    switch (fortuneType) {
      case 'Love':
        return 'Heart matters and meaningful bonds';
      case 'Career':
        return 'Professional growth and opportunities';
      case 'Wealth':
        return 'Financial wisdom and prosperity';
      case 'Health':
        return 'Physical and mental well-being';
      case 'Social':
        return 'Connections with others';
      case 'Growth':
        return 'Personal development and learning';
      case 'Advice':
        return 'Cosmic wisdom for today';
      default:
        return 'Personalized guidance awaits';
    }
  }

  IconData _getFortuneIcon(String fortuneType) {
    switch (fortuneType) {
      case 'Love':
        return Icons.favorite;
      case 'Career':
        return Icons.work;
      case 'Wealth':
        return Icons.attach_money;
      case 'Health':
        return Icons.local_hospital;
      case 'Social':
        return Icons.people;
      case 'Growth':
        return Icons.trending_up;
      case 'Advice':
        return Icons.help_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildFooterText() {
    return Center(
      child: Text(
        'edios fati',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class NoScrollbarBehavior extends ScrollBehavior {
  const NoScrollbarBehavior();
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
