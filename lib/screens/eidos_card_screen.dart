import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/analysis_report.dart';
import '../widgets/eidos_card.dart';
import '../constants/eidos_card_mappings.dart';

class EidosCardScreen extends StatefulWidget {
  final String eidosType;
  final Map<String, dynamic> analysisData;

  const EidosCardScreen({
    super.key,
    required this.eidosType,
    required this.analysisData,
  });

  @override
  State<EidosCardScreen> createState() => _EidosCardScreenState();
}

class _EidosCardScreenState extends State<EidosCardScreen> {
  List<String>? _cardUrls;
  bool _isLoading = true;
  String? _error;
  bool _isRevealed = false;
  int _selectedCardIndex = 0;
  String? _shortType;
  String? _description;
  List<String>? _keywords;

  @override
  void initState() {
    super.initState();
    _loadCardUrls();
  }

  Future<void> _loadCardUrls() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // EidosCardMappings에서 직접 URL 가져오기
      List<String>? urls = EidosCardMappings.cardUrls[widget.eidosType];

      // 정확한 매칭이 안 되면 부분 매칭 시도
      if (urls == null || urls.isEmpty) {
        // 에이도스 타입에서 키워드 추출하여 매칭 시도
        for (final entry in EidosCardMappings.cardUrls.entries) {
          if (entry.key.toLowerCase().contains(
                    widget.eidosType.toLowerCase(),
                  ) ||
              widget.eidosType.toLowerCase().contains(
                    entry.key.toLowerCase(),
                  )) {
            urls = entry.value;
            break;
          }
        }
      }

      // 여전히 매칭이 안 되면 키워드 기반 매칭 시도
      if (urls == null || urls.isEmpty) {
        // 에이도스 타입에서 키워드 추출
        final keywords = [
          'green mercenary',
          'golden pioneer',
          'free innovator',
          'creative affluent',
          'great manifestor',
          'indomitable explorer',
          'relationship artisan',
          'inner alchemist',
          'flexible strategist',
          'compassionate healer',
          'abyss explorer',
          'wise guide',
          'spiritual enlightener',
          'strong-willed lighthouse',
          'deep-rooted nurturer',
          'destiny integrator',
          'radiant creator',
          'resolute designer',
          'wise ruler',
        ];

        for (final keyword in keywords) {
          if (widget.eidosType.toLowerCase().contains(keyword)) {
            for (final entry in EidosCardMappings.cardUrls.entries) {
              if (entry.key.toLowerCase().contains(keyword)) {
                urls = entry.value;
                break;
              }
            }
            if (urls != null && urls.isNotEmpty) break;
          }
        }
      }

      if (urls == null || urls.isEmpty) {
        setState(() {
          _error = 'No cards found for type: ${widget.eidosType}';
          _isLoading = false;
        });
        return;
      }

      // 랜덤 카드 선택
      final random = Random();
      _selectedCardIndex = random.nextInt(urls.length);

      // 에이도스 타입 정보 설정
      _setEidosTypeInfo();

      setState(() {
        _cardUrls = urls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading cards: $e';
        _isLoading = false;
      });
    }
  }

  void _setEidosTypeInfo() {
    // 에이도스 타입에서 짧은 이름 추출
    final parts = widget.eidosType.split(' of ');
    if (parts.length >= 2) {
      _shortType = parts.last;
    } else {
      _shortType = widget.eidosType;
    }

    // 타입별 설명과 키워드 설정
    _setTypeDescription();
  }

  void _setTypeDescription() {
    switch (_shortType) {
      case 'Free Innovator':
        _description =
            'A visionary who breaks boundaries and creates new possibilities through innovative thinking and fearless exploration.';
        _keywords = ['Innovation', 'Freedom', 'Creativity', 'Vision'];
        break;
      case 'Creative Affluent':
        _description =
            'A master of abundance who combines artistic vision with practical wealth-building strategies.';
        _keywords = ['Abundance', 'Creativity', 'Wealth', 'Artistry'];
        break;
      case 'Great Manifestor':
        _description =
            'A powerful creator who transforms dreams into reality through focused intention and strategic action.';
        _keywords = ['Manifestation', 'Power', 'Creation', 'Achievement'];
        break;
      case 'Golden Pioneer':
        _description =
            'A trailblazer who leads others toward prosperity and success through bold initiatives and golden opportunities.';
        _keywords = ['Leadership', 'Prosperity', 'Pioneer', 'Success'];
        break;
      case 'Indomitable Explorer':
        _description =
            'An unstoppable adventurer who conquers new territories and overcomes any obstacle in their path.';
        _keywords = ['Adventure', 'Courage', 'Exploration', 'Determination'];
        break;
      case 'Relationship Artisan':
        _description =
            'A master of human connections who weaves beautiful relationships and creates harmony among people.';
        _keywords = ['Relationships', 'Harmony', 'Connection', 'Unity'];
        break;
      case 'Inner Alchemist':
        _description =
            'A transformative healer who transmutes pain into wisdom and darkness into light through inner work.';
        _keywords = ['Transformation', 'Healing', 'Wisdom', 'Alchemy'];
        break;
      case 'Flexible Strategist':
        _description =
            'An adaptive planner who navigates complex situations with grace and strategic flexibility.';
        _keywords = ['Strategy', 'Adaptability', 'Planning', 'Flexibility'];
        break;
      case 'Compassionate Healer':
        _description =
            'A gentle soul who brings healing and comfort to others through deep empathy and loving care.';
        _keywords = ['Healing', 'Compassion', 'Empathy', 'Care'];
        break;
      case 'Abyss Explorer':
        _description =
            'A deep seeker who ventures into the mysteries of existence and emerges with profound insights.';
        _keywords = ['Mystery', 'Depth', 'Insight', 'Wisdom'];
        break;
      case 'Green Mercenary':
        _description =
            'A nature-aligned warrior who harmonizes with natural forces and pioneers new paths with courage and wisdom.';
        _keywords = ['Nature', 'Courage', 'Pioneer', 'Harmony'];
        break;
      case 'Wise Guide':
        _description =
            'A wise mentor who guides others with deep knowledge and compassionate understanding.';
        _keywords = ['Wisdom', 'Guidance', 'Knowledge', 'Mentorship'];
        break;
      case 'Strong-willed Lighthouse':
        _description =
            'A beacon of strength and determination who stands firm in their convictions and guides others through storms.';
        _keywords = ['Strength', 'Determination', 'Leadership', 'Guidance'];
        break;
      case 'Deep-rooted Nurturer':
        _description =
            'A caring soul who provides deep, stable support and nurtures growth in others with patience and love.';
        _keywords = ['Nurturing', 'Stability', 'Care', 'Growth'];
        break;
      case 'Destiny Integrator':
        _description =
            'A master of balance who integrates different aspects of life and destiny into a harmonious whole.';
        _keywords = ['Balance', 'Integration', 'Harmony', 'Destiny'];
        break;
      case 'Radiant Creator':
        _description =
            'A brilliant creative force who brings light and inspiration to the world through artistic expression.';
        _keywords = ['Creativity', 'Inspiration', 'Art', 'Brilliance'];
        break;
      case 'Resolute Designer':
        _description =
            'A determined architect of reality who designs and builds lasting structures with unwavering focus.';
        _keywords = ['Design', 'Determination', 'Structure', 'Focus'];
        break;
      case 'Wise Ruler':
        _description =
            'A noble leader who rules with wisdom, justice, and compassion for the greater good of all.';
        _keywords = ['Leadership', 'Wisdom', 'Justice', 'Noble'];
        break;
      case 'Spiritual Enlightener':
        _description =
            'An enlightened being who brings spiritual wisdom and higher consciousness to others.';
        _keywords = [
          'Spirituality',
          'Enlightenment',
          'Wisdom',
          'Consciousness',
        ];
        break;
      default:
        _description =
            'A unique soul with special gifts and a distinctive path in life.';
        _keywords = ['Unique', 'Special', 'Gifted', 'Individual'];
    }
  }

  void _revealCard() {
    setState(() {
      _isRevealed = true;
    });
  }

  void _drawNewCard() {
    if (_cardUrls != null && _cardUrls!.length > 1) {
      final random = Random();
      int newIndex;
      do {
        newIndex = random.nextInt(_cardUrls!.length);
      } while (newIndex == _selectedCardIndex);

      setState(() {
        _selectedCardIndex = newIndex;
        _isRevealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Your Eidos Card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCardUrls,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 타입 제목
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withAlpha(128),
                              Colors.orange.withAlpha(64),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.amber.withAlpha(192),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _shortType ?? 'Unknown Type',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_description != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _description!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 카드
                      if (_cardUrls != null && _cardUrls!.isNotEmpty)
                        EidosCard(
                          imageUrl: _cardUrls![_selectedCardIndex],
                          title: _shortType ?? 'Eidos Card',
                          isRevealed: _isRevealed,
                          onTap: _isRevealed ? null : _revealCard,
                        ),

                      const SizedBox(height: 30),

                      // 키워드
                      if (_keywords != null && _isRevealed) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(107),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withAlpha(110),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Key Attributes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _keywords!.map((keyword) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withAlpha(120),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.amber.withAlpha(128),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      keyword,
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 버튼들
                      if (_isRevealed) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _drawNewCard,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Draw New Card'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Back to Report'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withAlpha(120),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(64),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.withAlpha(96),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Tap the card to reveal your Eidos guidance',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
