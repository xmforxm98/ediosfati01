import 'package:flutter/material.dart';
import 'package:innerfive/widgets/firebase_image.dart';

class FortuneCard extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? fortuneData;
  final String fortuneType;
  final String? backgroundImageUrl;
  final String? errorMessage;

  const FortuneCard({
    super.key,
    required this.isLoading,
    this.fortuneData,
    required this.fortuneType,
    this.backgroundImageUrl,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.5, // 1:2 비율 (width:height = 1:2)
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
          child: Stack(
            children: [
              // 1. Background Image
              if (backgroundImageUrl != null)
                Positioned.fill(
                  child: FirebaseImage(
                    storageUrl: backgroundImageUrl,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Positioned.fill(child: Container(color: Colors.grey[900])),

              // 2. Loading Indicator
              if (isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),

              // 3. Content Scrim
              if (!isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(128),
                          Colors.black.withAlpha(240),
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

              // 4. Content
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white.withAlpha(128),
                                size: 32,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(179),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : fortuneData == null
                          ? const Center(
                              child: Text(
                                'Coming Soon',
                                style: TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(flex: 3), // 상단 여백
                                Row(
                                  children: [
                                    Icon(
                                      _getFortuneIcon(fortuneType),
                                      color: Colors.white.withAlpha(150),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getFortuneTitle(fortuneType),
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(150),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  fortuneData!['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  fortuneData!['theme'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(128),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 1,
                                  width: 50,
                                  color: Colors.white.withAlpha(64),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Text(
                                    fortuneData!['description'] as String? ??
                                        '',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(136),
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
            ],
          ),
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
}
