import 'package:flutter/material.dart';

class EidosTypeCard extends StatelessWidget {
  final String typeName;
  final bool isHighlighted;

  const EidosTypeCard({
    super.key,
    required this.typeName,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isHighlighted ? const Color(0xFF3A3A3C) : const Color(0xFF2C2C2E);
    final borderColor = isHighlighted
        ? Colors.white.withOpacity(0.3)
        : Colors.white.withOpacity(0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              typeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isHighlighted)
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
        ],
      ),
    );
  }
}
