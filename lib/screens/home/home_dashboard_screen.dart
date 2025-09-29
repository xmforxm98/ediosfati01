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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:innerfive/widgets/firebase_image.dart';
import 'package:innerfive/utils/text_formatting_utils.dart';

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
  Map<String, dynamic>? _dailyEidosInsights; // 오늘의 Eidos 운세 데이터
  bool _isLoadingEidosInsights = false; // Eidos 운세 로딩 상태
  String? _todaysEnergyImageUrl; // 오늘의 에너지 이미지 URL

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

    // 초기 운세 데이터 로드
    _loadFortuneData(_selectedFortuneType);

    // 오늘의 Eidos 운세 로드
    _loadDailyEidosInsights();

    // 오늘의 에너지 이미지 로드
    _loadTodaysEnergyImage();
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
      setState(() {
        _latestReport = _latestReport;
        _isLoading = false;
      });

      // 초기 운세 데이터 로드
      _loadFortuneData(_selectedFortuneType);

      // 오늘의 Eidos 운세 로드
      _loadDailyEidosInsights();
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
      print('❌ Error loading fortune data: $e');
      setState(() {
        _isLoadingFortune = false;
      });
    }
  }

  Future<void> _loadDailyEidosInsights() async {
    if (_latestReport == null) {
      print('⚠️ No user report available for Eidos insights');
      return;
    }

    setState(() {
      _isLoadingEidosInsights = true;
      _dailyEidosInsights = null;
    });

    try {
      // Extract user data for API call
      String birthDate = '';
      String dayMaster = 'Fire';
      int lifePathNumber = 3;

      // Get birth date from user data
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['birthDate'] != null) {
            try {
              // Handle both Timestamp and String formats
              if (userData['birthDate'] is Timestamp) {
                final birthDateTime =
                    (userData['birthDate'] as Timestamp).toDate();
                birthDate =
                    '${birthDateTime.year}-${birthDateTime.month.toString().padLeft(2, '0')}-${birthDateTime.day.toString().padLeft(2, '0')}';
              } else if (userData['birthDate'] is String) {
                // If it's already a string in the correct format, use it directly
                birthDate = userData['birthDate'] as String;
              }
              print('🗓️ Birth date extracted: $birthDate');
            } catch (e) {
              print('⚠️ Error parsing birth date: $e, using default');
              birthDate = '1990-01-01'; // Default fallback
            }
          }
        }
      }

      // Get day master and life path number from report
      if (_latestReport!.rawDataForDev.isNotEmpty) {
        dayMaster =
            _latestReport!.rawDataForDev['day_master']?.toString() ?? 'Fire';
        lifePathNumber = int.tryParse(
                _latestReport!.rawDataForDev['life_path_number']?.toString() ??
                    '3') ??
            3;
      }

      print('🌟 Loading Eidos Daily Fortune with:');
      print('   - userName: $_userNickname');
      print('   - birthDate: $birthDate');
      print('   - dayMaster: $dayMaster');
      print('   - lifePathNumber: $lifePathNumber');

      // Validate required data
      if (birthDate.isEmpty) {
        print('⚠️ Birth date is empty, using default');
        birthDate = '1990-01-01';
      }

      // Call the new Eidos API
      final fortuneService = DailyFortuneService();
      final eidosData = await fortuneService.generateEidosDailyFortune(
        _userNickname,
        birthDate,
        dayMaster,
        lifePathNumber,
      );

      setState(() {
        _isLoadingEidosInsights = false;
        _dailyEidosInsights = eidosData;
      });

      print('✅ Eidos Daily Fortune loaded successfully');
    } catch (e) {
      print('❌ Error loading Eidos daily fortune: $e');
      setState(() {
        _isLoadingEidosInsights = false;
        _dailyEidosInsights = {
          'title': "Today's Eidos Insights",
          'description':
              'Unable to load your daily Eidos guidance. Please try again later.',
          'archetype_name': 'Your Eidos',
          'theme': 'Eidos Essence',
        };
      });
    }
  }

  /// 오늘의 날짜 기운에 맞는 에너지 이미지 선택
  String _getTodaysEnergyImage() {
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 5개 에너지 타입
    final energyTypes = [
      'EarthEnergy',
      'FireEnergy',
      'MetalEnergy',
      'WaterEnergy',
      'WoodEnergy'
    ];

    // 날짜를 기반으로 일관된 에너지 선택
    final energyIndex = dateString.hashCode.abs() % energyTypes.length;
    final selectedEnergy = energyTypes[energyIndex];

    // 각 에너지별로 4장 중 하나 선택
    final imageIndex =
        (dateString.hashCode.abs() ~/ energyTypes.length) % 4 + 1;
    final imageName = '$selectedEnergy$imageIndex.jpg';

    print(
        '🎨 Today\'s Energy Image: $imageName (Energy: $selectedEnergy, Index: $imageIndex)');

    return imageName;
  }

  /// tag_images에서 이미지 URL 가져오기
  Future<String?> _getTodaysEnergyImageUrl() async {
    try {
      final imageName = _getTodaysEnergyImage();
      final path = 'tag_images/$imageName';

      print('🎨 Fetching energy image: $path');

      final ref = FirebaseStorage.instance.ref().child(path);
      final url = await ref.getDownloadURL();

      print('✅ Got energy image URL: $url');
      return url;
    } catch (e) {
      print('❌ Error getting energy image URL: $e');
      return null;
    }
  }

  /// 오늘의 에너지 이미지 로드
  Future<void> _loadTodaysEnergyImage() async {
    try {
      final imageUrl = await _getTodaysEnergyImageUrl();
      setState(() {
        _todaysEnergyImageUrl = imageUrl;
      });
    } catch (e) {
      print('❌ Error loading today\'s energy image: $e');
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
                              // 첫 번째 위젯: 오늘의 에너지 카드 (FortuneCard 스타일)
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 상단 이미지 영역 (고정 높이)
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        child: _todaysEnergyImageUrl != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: FirebaseImage(
                                                    storageUrl:
                                                        _todaysEnergyImageUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[800],
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                              ),
                                      ),

                                      // 하단 텍스트 정보 영역 (유연한 높이)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: _isLoadingEidosInsights
                                            ? const SizedBox(
                                                height: 100,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                              )
                                            : Builder(
                                                builder: (context) {
                                                  // Use Eidos API data if available
                                                  if (_dailyEidosInsights !=
                                                      null) {
                                                    final title =
                                                        _dailyEidosInsights![
                                                                'title'] ??
                                                            "Today's Eidos Insights";
                                                    final archetypeName =
                                                        _dailyEidosInsights![
                                                                'archetype_name'] ??
                                                            'Your Eidos';
                                                    final description =
                                                        _dailyEidosInsights![
                                                                'description'] ??
                                                            'Your Eidos guidance is ready.';

                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          title,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          "🌟 $archetypeName",
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withAlpha(179),
                                                            fontSize: 14,
                                                            height: 1.4,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        TextFormattingUtils
                                                            .buildFormattedText(
                                                          description,
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withAlpha(136),
                                                            fontSize: 13,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }

                                                  // Fallback content while loading or if no data
                                                  String title =
                                                      "Today's Energy Insights";
                                                  String description =
                                                      "Your daily cosmic energy guidance is being prepared...";

                                                  if (_latestReport != null) {
                                                    final eidosType =
                                                        _latestReport!
                                                                .eidosSummary
                                                                .eidosType ??
                                                            _latestReport!
                                                                .eidosType ??
                                                            "Your Eidos";
                                                    title =
                                                        "Today's $eidosType Energy";
                                                    description =
                                                        "Experience today's cosmic energy through your unique Eidos perspective.";
                                                  }

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        title,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        "Daily Guidance",
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withAlpha(179),
                                                          fontSize: 14,
                                                          height: 1.4,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      TextFormattingUtils
                                                          .buildFormattedText(
                                                        description,
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withAlpha(136),
                                                          fontSize: 13,
                                                          height: 1.5,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 상단 여백
          const SizedBox(height: 40),

          // 메인 타이틀
          const Text(
            'Welcome to Eidos Fati',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // 서브 타이틀
          const Text(
            'Begin your journey of self-discovery. Let\'s analyze your unique energetic blueprint.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),

          // 기능 소개 카드들
          _buildFeatureCard(
            icon: Icons.auto_awesome,
            title: 'Discover Your Eidos Type',
            description: 'Uncover your unique cosmic personality archetype',
          ),
          const SizedBox(height: 16),

          _buildFeatureCard(
            icon: Icons.favorite,
            title: 'Daily Fortune Insights',
            description:
                'Get personalized guidance for love, career, and growth',
          ),
          const SizedBox(height: 16),

          _buildFeatureCard(
            icon: Icons.psychology,
            title: 'Tarot Wisdom',
            description: 'Receive your personal tarot card and daily readings',
          ),
          const SizedBox(height: 48),

          // CTA 버튼
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.white.withOpacity(0.3),
              ),
              child: const Text(
                'Explore My Destiny',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 하단 안내 텍스트
          Text(
            'It only takes 3 minutes to complete',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),

          // 하단 여백
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideX(duration: 600.ms, begin: 0.3, curve: Curves.easeOutCubic)
        .fadeIn(delay: 200.ms);
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
