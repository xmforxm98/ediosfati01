import 'package:flutter/material.dart';
import 'package:innerfive/widgets/firebase_image.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl.isNotEmpty;
    const defaultImageUrl =
        'https://storage.googleapis.com/innerfive-storage/golden_sage/The%20visionary%20verdant%20oracle%20of%20golden%20sage2.jpg';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: FirebaseImage(
                  storageUrl: hasImage ? imageUrl : defaultImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
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
}
