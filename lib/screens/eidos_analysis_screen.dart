import 'package:flutter/material.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/gradient_blurred_background.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:innerfive/utils/text_formatting_utils.dart';

class EidosAnalysisScreen extends StatefulWidget {
  final UserData userData;
  final Map<String, dynamic> analysisData;

  const EidosAnalysisScreen({
    super.key,
    required this.userData,
    required this.analysisData,
  });

  @override
  _EidosAnalysisScreenState createState() => _EidosAnalysisScreenState();
}

class _EidosAnalysisScreenState extends State<EidosAnalysisScreen> {
  final _inputController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _eidosCard;
  String? _errorMessage;

  Future<void> _analyzeEidos() async {
    if (_inputController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please share your thoughts or concerns.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 기존 분석 데이터를 사용하거나 새로운 분석 요청
      final analysisData = widget.analysisData ??
          await _apiService.getAnalysisReport({
            'name': widget.userData.nickname ??
                '${widget.userData.firstName} ${widget.userData.lastName}',
            'year': int.tryParse(widget.userData.year ?? '') ?? 1990,
            'month': int.tryParse(widget.userData.month ?? '') ?? 1,
            'day': int.tryParse(widget.userData.day ?? '') ?? 1,
            'hour': int.tryParse(widget.userData.hour ?? '') ?? 12,
            'gender': widget.userData.gender == Gender.male ? 'male' : 'female',
            'birth_city': widget.userData.city ?? 'Seoul',
            'user_input': _inputController.text.trim(), // 사용자 입력 추가
          });

      setState(() {
        // 에이도스 카드 정보를 분석 데이터에서 추출
        _eidosCard = {
          'name': analysisData['eidos_type'] ?? 'Unknown Type',
          'type_id': analysisData['eidos_summary']?['group_id'] ?? 'N/A',
          'main_type':
              analysisData['eidos_summary']?['title'] ?? 'Eidos Analysis',
          'core_characteristics': analysisData['eidos_summary']
                  ?['summary_text'] ??
              'No description available',
          'symbol_keywords': analysisData['eidos_summary']
                  ?['current_energy_text'] ??
              'No keywords available',
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to analyze Eidos: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(64), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Share Your Thoughts",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "What's on your mind? What challenges are you facing? What do you hope to achieve?",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  "Express your thoughts, concerns, dreams, or questions about your path...",
              hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
              filled: true,
              fillColor: Colors.white.withAlpha(32),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withAlpha(64)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          CustomButton(
            text: _isLoading ? "Analyzing..." : "Reveal My Eidos",
            onPressed: _isLoading ? () {} : _analyzeEidos,
          ),
        ],
      ),
    );
  }

  Widget _buildEidosCard() {
    if (_eidosCard == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withAlpha(128),
                      Colors.blue.withAlpha(128),
                      Colors.indigo.withAlpha(128),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.amber, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _eidosCard!['name'] ?? 'Unknown Type',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(32),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _eidosCard!['type_id'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _eidosCard!['main_type'] ?? 'Core Identity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "🌟 Your Eidos Essence",
                    style: TextStyle(
                      color: Colors.white.withAlpha(179),
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormattingUtils.buildFormattedText(
                    _eidosCard!['core_characteristics'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withAlpha(136),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  if (_eidosCard!['symbol_keywords'] != null &&
                      _eidosCard!['symbol_keywords']!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.palette,
                            color: Colors.amber.withAlpha(179), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Symbols:',
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormattingUtils.buildFormattedText(
                      _eidosCard!['symbol_keywords'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(136),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (_eidosCard!['card_message'] != null &&
                      _eidosCard!['card_message']!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.amber.withAlpha(32),
                            Colors.orange.withAlpha(32),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.amber.withAlpha(64), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_stories,
                                  color: Colors.amber.withAlpha(179), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Your Destiny Message',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(179),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormattingUtils.buildFormattedText(
                            _eidosCard!['card_message'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(136),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eidos Destiny Analysis"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: GradientBlurredBackground(
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/eidosfati.appspot.com/o/backgrounds%2Fbackground_4.jpg?alt=media',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Discover Your Eidos Essence",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Based on your birth data and numerological profile, we'll analyze your deepest thoughts to reveal your unique Eidos destiny type from 60 possible essences.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(128),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildInputSection(),
              _buildEidosCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
