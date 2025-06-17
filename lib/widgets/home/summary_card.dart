import 'package:flutter/material.dart';
import 'package:innerfive/models/analysis_report.dart';
import 'package:innerfive/utils/daily_message_generator.dart';
import 'package:innerfive/utils/tag_image_manager.dart';

class SummaryCard extends StatelessWidget {
  final NarrativeReport? latestReport;
  final String ganzhiDate;
  final String userNickname;

  const SummaryCard({
    super.key,
    this.latestReport,
    required this.ganzhiDate,
    required this.userNickname,
  });

  @override
  Widget build(BuildContext context) {
    String eidosTitle = latestReport?.eidosSummary.title ?? "your unique Eidos";
    final dayGanzhi = ganzhiDate.replaceAll(' Day', '');
    final dailyMessage = DailyMessageGenerator.generateMessage(
      userName: userNickname,
      eidosType: eidosTitle,
      ganzhi: dayGanzhi,
    );
    String todayMessage = dailyMessage.text;
    List<String> hashtags = dailyMessage.hashtags;
    final tagImageUrl = TagImageManager.getImageUrlForHashtags(hashtags);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(
        minHeight: 600,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: tagImageUrl != null
                  ? Image.network(
                      tagImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.withAlpha(128),
                                Colors.purple.withAlpha(128),
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
                            Colors.blue.withAlpha(128),
                            Colors.purple.withAlpha(128),
                          ],
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 260),
                  Text(
                    "Today's Energy",
                    style: TextStyle(
                      color: Colors.white.withAlpha(128),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  Text(
                    latestReport?.ryusWisdom.message ??
                        "We're preparing your cosmic insights...",
                    style: TextStyle(
                      color: Colors.white.withAlpha(128),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                          color: Colors.white.withAlpha(128),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withAlpha(128),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
