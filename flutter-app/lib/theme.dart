import 'package:flutter/material.dart';

const Color neonGreen = Color(0xFF39FF14);

class AppTheme {
  static ThemeData get generalTheme {
    return ThemeData(
      // Основные цвета
      primaryColor: neonGreen,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        iconTheme: IconThemeData(color: neonGreen),
        titleTextStyle: TextStyle(
          color: neonGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(
        color: neonGreen,
        shadows: [Shadow(color: neonGreen, blurRadius: 4)],
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        labelSmall: TextStyle(color: Colors.grey, fontSize: 12),
        labelMedium: TextStyle(color: Colors.grey, fontSize: 12),
        titleLarge: TextStyle(color: neonGreen, fontSize: 24, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: neonGreen, fontSize: 20, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: neonGreen, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: neonGreen,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonGreen,
        foregroundColor: Colors.black,
      ),
      cardTheme: CardTheme(
        color: Colors.grey[850],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: neonGreen),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: neonGreen),
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
        labelStyle: const TextStyle(color: neonGreen),
      ),
    );
  }
}