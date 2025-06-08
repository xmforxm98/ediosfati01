import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor; // Used when isOutlined is true

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.backgroundColor = const Color.fromARGB(
      255,
      255,
      255,
      255,
    ), // Default background, can be themed
    this.textColor = const Color.fromARGB(255, 255, 255, 255),
    this.borderColor = const Color.fromARGB(
      101,
      255,
      255,
      255,
    ), // Default border color for outlined button
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        isOutlined
            ? OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(
                color: borderColor,
                width: 1.5,
              ), // Ensure border is visible
              minimumSize: const Size(double.infinity, 50),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            )
            : ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor:
                  textColor, // For ElevatedButton, foregroundColor is the text/icon color
              minimumSize: const Size(double.infinity, 50),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            );

    return SizedBox(
      width: double.infinity,
      height: 50,
      child:
          isOutlined
              ? OutlinedButton(
                style: style,
                onPressed: onPressed,
                child: Text(text),
              )
              : ElevatedButton(
                style: style,
                onPressed: onPressed,
                child: Text(text),
              ),
    );
  }
}
