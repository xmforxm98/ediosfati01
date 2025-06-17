import 'package:flutter/material.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/gradient_blurred_background.dart';
import 'package:innerfive/services/api_service.dart';
import 'package:innerfive/widgets/custom_button.dart';

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
      final eidosData = await _apiService.getEidosAnalysis(
        _inputController.text.trim(),
        widget.userData.nickname ??
            '${widget.userData.firstName} ${widget.userData.lastName}',
      );

      setState(() {
        _eidosCard = eidosData['eidos_card'];
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withAlpha(64),
            Colors.blue.withAlpha(64),
            Colors.indigo.withAlpha(64),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(64), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              const Spacer(),
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _eidosCard!['name'] ?? 'Unknown Type',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _eidosCard!['main_type'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(128),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _eidosCard!['core_characteristics'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(192),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.palette, color: Colors.amber, size: 16),
              SizedBox(width: 8),
              Text(
                'Symbols:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _eidosCard!['symbol_keywords'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(128),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.withAlpha(64),
                  Colors.orange.withAlpha(64),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_stories, color: Colors.amber, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Your Destiny Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _eidosCard!['card_message'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
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
