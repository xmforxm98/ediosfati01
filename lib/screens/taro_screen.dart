import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/services/tarot_service.dart';

class TaroScreen extends StatefulWidget {
  const TaroScreen({super.key});

  @override
  State<TaroScreen> createState() => _TaroScreenState();
}

class _TaroScreenState extends State<TaroScreen> {
  TarotInsight? _tarotInsight;
  Map<String, String>? _cardInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTarotData();
  }

  Future<void> _loadTarotData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = "Please log in to view your tarot reading.";
        _isLoading = false;
      });
      return;
    }

    try {
      final readingsQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('readings')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (readingsQuery.docs.isNotEmpty) {
        final latestReadingData = readingsQuery.docs.first.data();
        if (latestReadingData.containsKey('report')) {
          final report = NarrativeReport.fromJson(
            latestReadingData['report'] as Map<String, dynamic>,
          );
          setState(() {
            _tarotInsight = report.tarotInsight;
            // Get tarot card image info based on the card title
            if (_tarotInsight?.cardTitle != null) {
              _cardInfo = TarotService.getCardInfo(_tarotInsight!.cardTitle);
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "No tarot data found in your analysis.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Complete an analysis first to see your tarot reading.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading tarot data: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Taro', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadTarotData();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadTarotData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTarotCard(),
          const SizedBox(height: 24),
          _buildTarotMeaning(),
          const SizedBox(height: 24),
          _buildTarotMessage(),
        ],
      ),
    );
  }

  Widget _buildTarotCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
            Colors.indigo.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Card Title
          Text(
            _cardInfo?['displayName'] ??
                _tarotInsight?.cardTitle ??
                'Your Tarot Card',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Card Image
          if (_cardInfo?['imageUrl'] != null) ...[
            Container(
              height: 300,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _cardInfo!['imageUrl']!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 300,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tarot Card',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ] else ...[
            Container(
              height: 300,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tarot Card',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          Text(
            'Your Card of Destiny',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          // New Card Button
          ElevatedButton.icon(
            onPressed: () {
              if (_tarotInsight?.cardTitle != null) {
                setState(() {
                  _cardInfo = TarotService.getCardInfo(
                    _tarotInsight!.cardTitle,
                  );
                });
              }
            },
            icon: const Icon(Icons.refresh, color: Colors.black),
            label: const Text(
              'Draw New Variation',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarotMeaning() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Card Meaning',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _tarotInsight?.cardMeaning ??
                  'Your tarot insight will appear here.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarotMessage() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tarotInsight?.cardMessageTitle ?? 'Message From the Card',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _tarotInsight?.cardMessageText ??
                  'Complete your analysis to receive a personalized message.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
