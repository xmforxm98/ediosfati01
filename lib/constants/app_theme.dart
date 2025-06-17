import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1a1a1a),
    scaffoldBackgroundColor: const Color(0xFF1a1a1a),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.blueAccent,
      surface: Color(0xFF2c2c2c),
    ),
    fontFamily: 'Roboto',
  );
}
