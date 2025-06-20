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
import 'package:innerfive/utils/tag_image_manager.dart';
import 'package:innerfive/services/daily_fortune_service.dart';
import 'package:innerfive/services/image_service.dart';
import 'package:innerfive/widgets/home/fortune_card.dart';
import 'package:innerfive/widgets/home/summary_card.dart';
import 'package:innerfive/screens/onboarding/onboarding_flow_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(NarrativeReport) onNavigateToReport;

  const HomeDashboardScreen({super.key, required this.onNavigateToReport});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  User? _user;
  NarrativeReport? _latestReport;
  String _userName = 'User';
  String _userNickname = 'User';
  bool _isLoading = true;
  Map<String, List<String>> _eidosCardUrls = {};
  final List<String> _currentEidosImageUrls = [];

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
          final displayName =
              userData['displayName'] ?? _user?.displayName ?? 'User';
          final nickname = userData['nickname'];

          print('🔍 User data check:');
          print('   - UID: ${_user!.uid}');
          print('   - displayName: $displayName');
          print('   - nickname: $nickname');
          print('   - userData keys: ${userData.keys.toList()}');

          setState(() {
            _userName = displayName;
            // 닉네임을 우선적으로 사용하고, 없거나 N/A인 경우에만 displayName 사용
            if (nickname != null &&
                nickname != 'N/A' &&
                nickname.toString().trim().isNotEmpty &&
                nickname.toString().trim() != 'null') {
              _userNickname = nickname;
              print('✅ Using nickname: $_userNickname');
            } else if (displayName != 'N/A' && displayName.trim().isNotEmpty) {
              _userNickname = displayName;
              print(
                  '⚠️ Using displayName: $_userNickname (nickname: $nickname)');
            } else {
              // Last resort: generate email-based nickname
              final emailBasedName = _user?.email?.split('@')[0] ?? 'User';
              _userNickname = emailBasedName;
              print('📧 Using email-based nickname: $_userNickname');
            }
          });
        } else {
          // Firestore 문서가 없는 경우 - 기본값 설정
          final displayName =
              _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User';
          print('📄 Firestore 문서 없음 - 기본값 설정: $displayName');
          setState(() {
            _userName = displayName;
            _userNickname = displayName;
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        final displayName =
            _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User';
        print('❌ 사용자 데이터 로드 오류 - 기본값 설정: $displayName');
        setState(() {
          _userName = displayName;
          _userNickname = displayName != 'N/A' && displayName.isNotEmpty
              ? displayName
              : (_user?.email?.split('@')[0] ?? 'User');
        });
      }

      // Fetch latest report from Firestore
      await _loadLatestReport();
    }
  }

  Future<void> _loadLatestReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        print('🏠 Home: Loading latest report for user: ${user.uid}');
        final readingsQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('readings')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        print('🏠 Home: Found ${readingsQuery.docs.length} readings');
        if (readingsQuery.docs.isNotEmpty) {
          final latestReadingData = readingsQuery.docs.first.data();
          if (latestReadingData.containsKey('report')) {
            dynamic reportData = latestReadingData['report'];

            // Defensive coding: handle case where data might be a JSON string
            if (reportData is String) {
              try {
                reportData = jsonDecode(reportData);
              } catch (e) {
                print('Error decoding report string: $e');
                _latestReport = null;
              }
            }

            if (reportData is Map<String, dynamic>) {
              _latestReport = NarrativeReport.fromJson(reportData);
            }
          }
        }
      } catch (e) {
        print("Error loading latest report: $e");
        _latestReport = null;
      }
    }
    if (mounted) {
      setState(() {});
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
      body: ScrollConfiguration(
        behavior: const _NoScrollbarBehavior(),
        child: CustomScrollView(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _latestReport == null
                        ? _buildInitialPrompt()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopHeader()
                                  .animate()
                                  .slideY(
                                      duration: 500.ms,
                                      begin: -0.2,
                                      curve: Curves.easeOut)
                                  .fadeIn(),
                              const SizedBox(height: 16),
                              SummaryCard(
                                title:
                                    _latestReport?.eidosSummary.summaryTitle ??
                                        "Eidos Summary",
                                description:
                                    _latestReport?.eidosSummary.eidosType ??
                                        "Tap to see details",
                                imageUrl: '',
                                onTap: () {
                                  if (_latestReport != null) {
                                    widget.onNavigateToReport(_latestReport!);
                                  }
                                },
                              )
                                  .animate()
                                  .slideX(
                                      duration: 500.ms,
                                      begin: -0.2,
                                      curve: Curves.easeOut)
                                  .fadeIn(delay: 200.ms),
                              const SizedBox(height: 16),
                              _buildDailyFortuneSection()
                                  .animate()
                                  .slideY(
                                      duration: 500.ms,
                                      begin: 0.2,
                                      curve: Curves.easeOut)
                                  .fadeIn(delay: 400.ms),
                              const SizedBox(height: 48),
                              _buildFooterText(),
                              const SizedBox(height: 100), // 네비게이션 바 공간 확보
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialPrompt() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Eidos Fati',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Begin your journey of self-discovery. Let\'s analyze your unique energetic blueprint.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OnboardingFlowScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Explore My Destiny',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildDailyFortuneSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          _buildFortuneTabBar(),
          const SizedBox(height: 24),
          _buildFortuneCard(),
        ],
      ),
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

    return Center(
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: fortuneTypes.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final fortune = fortuneTypes[index];
            final isSelected =
                _selectedFortuneType == fortune['title'] as String;

            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _onFortuneTypeSelected(fortune['title'] as String),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withAlpha(255)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isSelected
                              ? fortune['icon_filled'] as IconData
                              : fortune['icon_outlined'] as IconData,
                          color: isSelected
                              ? Colors.black
                              : Colors.white.withAlpha(102),
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
                            : Colors.white.withAlpha(102),
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
      ),
    );
  }

  void _onFortuneTypeSelected(String fortuneType) {
    if (_selectedFortuneType == fortuneType) return;

    setState(() {
      _selectedFortuneType = fortuneType;
      _currentFortuneData = null;
      _isLoadingFortune = true;
    });

    _loadFortuneData(fortuneType);
  }

  Widget _buildFortuneCard() {
    final today = DateTime.now().toIso8601String().split('T')[0];

    return FutureBuilder<String?>(
      future: ImageService.getConsistentFortuneBackgroundUrl(
        _selectedFortuneType,
        _userNickname,
        today,
      ),
      builder: (context, snapshot) {
        final backgroundImageUrl = snapshot.data;

        return FortuneCard(
          isLoading: _isLoadingFortune,
          fortuneData: _currentFortuneData,
          fortuneType: _selectedFortuneType,
          backgroundImageUrl: backgroundImageUrl,
        );
      },
    );
  }

  Widget _buildFooterText() {
    return Center(
      child: Text(
        'edios fati',
        style: TextStyle(
          color: Colors.white.withAlpha(128),
          fontSize: 14,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
