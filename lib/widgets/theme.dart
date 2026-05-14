import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF1B6CA8);
  static const Color primaryDark = Color(0xFF0D4F80);
  static const Color primaryLight = Color(0xFFE8F4FD);
  static const Color accent = Color(0xFFF4A335);
  static const Color accentLight = Color(0xFFFFF3E0);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFFDE7);
  static const Color surface = Color(0xFFF8FAFB);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
  static const Color darkSecondaryText = Color(0xFFB0B0B0);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF5A6A7A);
  static const Color textLight = Color(0xFF8A9AAA);
  static const Color divider = Color(0xFFEEF2F6);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(primary: primary, secondary: accent, surface: surface),
    scaffoldBackgroundColor: surface,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: divider, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textLight),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryLight,
      labelStyle: const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    scaffoldBackgroundColor: darkSurface,

    cardColor: darkCard,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(primary: primary, secondary: accent, surface: darkCard),

    appBarTheme: const AppBarTheme(backgroundColor: darkSurface, foregroundColor: Colors.white, elevation: 0, centerTitle: false),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCard,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: divider),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: divider),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: primary, width: 2),
      ),

      labelStyle: const TextStyle(color: darkSecondaryText),

      hintStyle: const TextStyle(color: darkSecondaryText),
    ),
  );
}

class AppConstants {
  static const List<String> categories = [
    'All',
    'Environment',
    'Animals',
    'Education',
    'Social',
    'Health',
    'Arts & Media',
    'Sports',
    'Technology',
    'Other',
  ];

  static const List<String> allSkills = [
    'Teaching',
    'Childcare',
    'Medical',
    'Physical Work',
    'Photography',
    'Social Media',
    'Event Planning',
    'Coding',
    'Design',
    'Cooking',
    'Driving',
    'Languages',
    'Music',
    'Legal',
    'Accounting',
    'Fundraising',
  ];

  static const Map<String, String> categoryEmojis = {
    'Environment': '🌿',
    'Animals': '🐾',
    'Education': '📚',
    'Social': '🤝',
    'Health': '❤️',
    'Arts & Media': '🎨',
    'Sports': '⚽',
    'Technology': '💻',
    'Other': '✨',
  };

  static const Map<String, Color> categoryColors = {
    'Environment': Color(0xFF2E7D32),
    'Animals': Color(0xFF6A1B9A),
    'Education': Color(0xFF1565C0),
    'Social': Color(0xFFE65100),
    'Health': Color(0xFFC62828),
    'Arts & Media': Color(0xFF00838F),
    'Sports': Color(0xFF558B2F),
    'Technology': Color(0xFF283593),
    'Other': Color(0xFF4E342E),
  };
}
