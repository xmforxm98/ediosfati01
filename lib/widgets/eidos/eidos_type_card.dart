import 'package:flutter/material.dart';
import 'package:innerfive/widgets/firebase_image.dart';

class EidosTypeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const EidosTypeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2C2C2E);
    final borderColor = Colors.white.withOpacity(0.08);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FirebaseImage(storageUrl: imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
