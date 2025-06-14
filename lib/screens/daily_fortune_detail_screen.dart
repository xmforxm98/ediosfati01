import 'package:flutter/material.dart';
import '../models/analysis_report.dart';
import '../services/daily_fortune_service.dart';
import '../services/fortune_background_service.dart';

class DailyFortuneDetailScreen extends StatefulWidget {
  final String fortuneType;
  final NarrativeReport? userProfile;
  final String? userName;

  const DailyFortuneDetailScreen({
    super.key,
    required this.fortuneType,
    this.userProfile,
    this.userName,
  });

  @override
  State<DailyFortuneDetailScreen> createState() =>
      _DailyFortuneDetailScreenState();
}

class _DailyFortuneDetailScreenState extends State<DailyFortuneDetailScreen> {
  Map<String, dynamic>? _fortuneData;
  bool _isLoading = true;
  String? _backgroundImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // FortuneBackgroundService 초기화
    await FortuneBackgroundService.loadBackgroundUrls();

    // 배경 이미지 URL 가져오기 (사용자별 일관된 이미지)
    final today = DateTime.now().toIso8601String().split('T')[0];
    _backgroundImageUrl = FortuneBackgroundService.getConsistentBackgroundUrl(
      widget.fortuneType,
      widget.userName ?? 'User',
      today,
    );

    // 강제 테스트: 항상 배경 이미지 사용
    final fortuneTypeMap = {
      'Love': 'love1.png',
      'Career': 'career1.png',
      'Wealth': 'wealth1.png',
      'Health': 'health1.png',
      'Social': 'social1.png',
      'Growth': 'growth1.png',
    };

    final imageFile = fortuneTypeMap[widget.fortuneType] ?? 'love1.png';
    _backgroundImageUrl =
        'https://storage.googleapis.com/innerfive.firebasestorage.app/fortune_backgrounds/$imageFile';
    print('🔧 Force using background image: $_backgroundImageUrl');

    print('🖼️ Background Image Debug:');
    print('  - Fortune Type: ${widget.fortuneType}');
    print('  - User Name: ${widget.userName ?? 'User'}');
    print('  - Date: $today');
    print('  - Background URL: $_backgroundImageUrl');

    await _loadFortuneData();
  }

  Future<void> _loadFortuneData() async {
    try {
      final fortuneService = DailyFortuneService();
      final data = await fortuneService.generateDailyFortune(
        widget.fortuneType,
        widget.userProfile,
        widget.userName ?? 'User',
      );

      setState(() {
        _fortuneData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading fortune data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getFortuneTitle(widget.fortuneType),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: _backgroundImageUrl != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_backgroundImageUrl!),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print('❌ Background image failed to load: $exception');
                    print('URL: $_backgroundImageUrl');
                  },
                ),
              )
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1a1a1a),
                    Color(0xFF000000),
                  ],
                ),
              ),
        child: Container(
          // 배경 이미지 위에 어두운 오버레이 추가
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : _buildFortuneContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFortuneContent() {
    if (_fortuneData == null) {
      return const Center(
        child: Text(
          'Unable to load fortune data',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildIllustrationPlaceholder(),
          const SizedBox(height: 32),
          _buildFortuneHeader(),
          const SizedBox(height: 24),
          _buildFortuneMessage(),
          const SizedBox(height: 24),
          _buildKeywords(),
          const SizedBox(height: 32),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildIllustrationPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFortuneIcon(widget.fortuneType),
            color: Colors.white.withOpacity(0.9),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _getFortuneTitle(widget.fortuneType),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Today\'s Guidance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getFortuneIcon(widget.fortuneType),
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fortuneData!['title'] ?? _getFortuneTitle(widget.fortuneType),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _fortuneData!['subtitle'] ?? _getFortuneSubtitle(widget.fortuneType),
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildFortuneMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        _fortuneData!['message'] ??
            'Your personalized fortune message will appear here.',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildKeywords() {
    final keywords = _fortuneData!['keywords'] as List<String>? ?? [];

    if (keywords.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Themes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              keywords.map((keyword) => _buildKeywordChip(keyword)).toList(),
        ),
      ],
    );
  }

  Widget _buildKeywordChip(String keyword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        keyword,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 16,
          ),
        ),
        onPressed: () {
          // Navigate to new analysis or other action
          Navigator.pushNamed(context, '/new_analysis');
        },
        child: const Text(
          'Get New Analysis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getFortuneTitle(String fortuneType) {
    switch (fortuneType) {
      case 'Love':
        return 'Love & Relationship Fortune';
      case 'Career':
        return 'Career & Work Fortune';
      case 'Wealth':
        return 'Wealth & Finance Fortune';
      case 'Health':
        return 'Health & Well-being Fortune';
      case 'Social':
        return 'Interpersonal Relationship Fortune';
      case 'Growth':
        return 'Growth & Development Fortune';
      case 'Advice':
        return 'Lucky Advice of the Day';
      default:
        return 'Daily Fortune';
    }
  }

  String _getFortuneSubtitle(String fortuneType) {
    switch (fortuneType) {
      case 'Love':
        return 'Romantic relationships and connections';
      case 'Career':
        return 'Work performance and opportunities';
      case 'Wealth':
        return 'Financial flow and investments';
      case 'Health':
        return 'Physical and mental well-being';
      case 'Social':
        return 'Friends, colleagues, and family';
      case 'Growth':
        return 'Learning and self-development';
      case 'Advice':
        return 'Comprehensive guidance for today';
      default:
        return 'Your personalized daily guidance';
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
        return Icons.health_and_safety;
      case 'Social':
        return Icons.group;
      case 'Growth':
        return Icons.trending_up;
      case 'Advice':
        return Icons.lightbulb;
      default:
        return Icons.star;
    }
  }
}
