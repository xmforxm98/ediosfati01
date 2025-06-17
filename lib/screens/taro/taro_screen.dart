import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/models/daily_tarot.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/services/tarot_service.dart';
import 'package:innerfive/widgets/home/fortune_card.dart';

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
          final report = NarrativeReport.fromJson(
            latestReadingData['report'] as Map<String, dynamic>,
          );

          // Card 1: Eidos Tarot (from existing analysis)
          final tarotInsight = report.tarotInsight;
          final cardInfo = TarotService.getCardInfo(tarotInsight.cardTitle);
          tarotCards.add({
            'type': 'Eidos Tarot',
            'title': cardInfo['displayName'] ?? tarotInsight.cardTitle,
            'subtitle': 'Your Eidos-based Tarot Reading',
            'message': tarotInsight.cardMessageText,
            'backgroundImageUrl': cardInfo['imageUrl'],
          });

          // Card 2: Daily Tarot (from new API)
          try {
            final userProfile = {
              'name': user.displayName ?? 'Friend',
              'eidos_type': report.eidosSummary.eidosType ?? 'Unknown',
              'saju': report.rawDataForDev['saju'] ?? {},
            };
            final dailyTarot = await _apiService.getDailyTarot(userProfile);
            _dailyTarot = dailyTarot;
            tarotCards.add({
              'type': 'Daily Tarot',
              'title': dailyTarot.cardNameDisplay,
              'subtitle': 'Your Tarot for Today',
              'message': dailyTarot.message.content,
              'backgroundImageUrl': dailyTarot.cardImageUrl,
            });
          } catch (e) {
            print("Failed to load daily tarot: $e");
            // API 호출 실패 시 에러메시지를 담은 카드를 추가하여 사용자에게 피드백
            tarotCards.add({
              'type': 'Daily Tarot',
              'title': 'Error',
              'subtitle': 'Could not load Daily Tarot',
              'message':
                  'There was an error fetching your daily reading. Please try again later.\n\nDetails: $e',
              'backgroundImageUrl': '', // 혹은 에러 상태를 나타내는 기본 이미지
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
    } catch (e) {
      _errorMessage = "An error occurred while loading data: $e";
      print(_errorMessage); // for debugging
    }

    setState(() {
      _isLoading = false;
    });
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
            'Taro Card',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildTabBar(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _tarotDataList!.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final fortune = _tarotDataList![index];
                return FractionallySizedBox(
                  widthFactor: 0.8,
                  child: FortuneCard(
                    isLoading: false,
                    fortuneData: {
                      'title': fortune['title'],
                      'subtitle': fortune['subtitle'],
                      'message': fortune['message'],
                    },
                    fortuneType: fortune['type'],
                    backgroundImageUrl: fortune['backgroundImageUrl'],
                  ),
                );
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
      return const SizedBox(height: 24); // Add some space if no tabs
    }

    final List<Map<String, dynamic>> tabsInfo = _tarotDataList!.map((data) {
      String type = data['type'] as String? ?? '';
      if (type == 'Eidos Tarot') {
        return {
          'name': 'Your Tarot',
        };
      } else if (type == 'Daily Tarot') {
        return {
          'name': 'Today\'s Tarot',
        };
      } else {
        return {
          'name': 'Tarot',
        }; // Fallback
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

  Widget _buildDailyTarotPage() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (_error != null) {
      return Center(
          child: Text('Error: $_error',
              style: const TextStyle(color: Colors.red)));
    }
    if (_dailyTarot == null) {
      return const Center(
          child: Text('No tarot data available.',
              style: TextStyle(color: Colors.white)));
    }

    // Use a Map for the fortuneData
    final fortuneData = {
      'message': {
        'title': _dailyTarot!.message.title,
        'content': _dailyTarot!.message.content,
        'sections': _dailyTarot!.message.sections
            .map((s) => {'title': s.title, 'content': s.content})
            .toList(),
        'aphorism': _dailyTarot!.message.aphorism,
        'hashtags': _dailyTarot!.message.hashtags,
      },
      'card_name_display': _dailyTarot!.cardNameDisplay,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FortuneCard(
            fortuneData: fortuneData,
            fortuneType: 'Tarot',
            backgroundImageUrl: _dailyTarot!.cardImageUrl,
            isLoading: false,
          ),
        ],
      ),
    );
  }

  // Helper to build the Eidos Tarot content
  Widget _buildEidosTarotPage() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (_errorMessage != null) {
      return Center(
          child: Text('Error: $_errorMessage',
              style: const TextStyle(color: Colors.red)));
    }
    if (_tarotDataList == null || _tarotDataList!.isEmpty) {
      return const Center(
          child: Text('No tarot data available.',
              style: TextStyle(color: Colors.white)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Page content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 2, // Eidos Tarot and Daily Tarot
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Eidos Tarot Page
                  return _buildEidosTarotPage();
                } else {
                  // Daily Tarot Page
                  return _buildDailyTarotPage();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
