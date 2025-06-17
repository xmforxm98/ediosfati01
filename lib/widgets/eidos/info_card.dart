import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl; // Optional image

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // From FortuneCard style
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool hasFiniteHeight = constraints.maxHeight.isFinite;

            final textContent = Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withAlpha(136),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl != null)
                  Stack(
                    children: [
                      Image.network(
                        imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                                height: 180,
                                child: Center(
                                    child: Icon(Icons.error_outline,
                                        color: Colors.white24))),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF1C1C1E).withOpacity(0.7),
                                const Color(0xFF1C1C1E),
                              ],
                              stops: const [0.5, 0.9, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (hasFiniteHeight)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: imageUrl != null
                            ? const EdgeInsets.fromLTRB(20, 0, 20, 20)
                            : const EdgeInsets.all(20),
                        child: textContent,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: imageUrl != null
                        ? const EdgeInsets.fromLTRB(20, 0, 20, 20)
                        : const EdgeInsets.all(20),
                    child: textContent,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
