import 'dart:ui';

class AppColors {
  // Primary Colors - Dark theme with glassmorphism
  static const Color primaryColor = Color(0xFFf97316); // orange
  static const Color primaryLightColor = Color(0xFFfb923c); // light orange
  static const Color primaryDarkColor = Color(0xFFea580c); // Dark orange

  // Base Colors
  static const Color blackColor = Color(0xFF000000);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color transparentColor = Color(0x00000000);

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF1a1a2e); // Dark Navy
  static const Color darkSecondaryColor = Color(0xFF16213e); // Darker Navy
  static const Color darkTertiaryColor = Color(0xFF0f3460); // Deep Navy

  // Glass Colors
  static const Color glassColor = Color(0x26FFFFFF); // 15% white opacity
  static const Color glassLightColor = Color(0x40FFFFFF); // 25% white opacity
  static const Color glassBorderColor = Color(0x4DFFFFFF); // 30% white opacity

  // Text Colors
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xB3FFFFFF); // 70% white opacity
  static const Color textTertiaryColor = Color(0x80FFFFFF); // 50% white opacity

  // Accent Colors
  static const Color accentBlueColor = Color(0xFF3b82f6);
  static const Color accentPurpleColor = Color(0xFF8b5cf6);
  static const Color accentCyanColor = Color(0xFF06b6d4);
  static const Color accentPinkColor = Color(0xFFec4899);

  // Status Colors
  static const Color successColor = Color(0xFF10b981);
  static const Color warningColor = Color(0xFFf59e0b);
  static const Color errorColor = Color(0xFFef4444);
  static const Color infoColor = Color(0xFF3b82f6);

  // Legacy Colors (for backward compatibility)
  static const Color orangeColor = Color(0xFFf97316);
  static const Color lightOrangeColor = Color(0xFFfb923c);
  static const Color darkOrangeColor = Color(0xFFea580c);
  static const Color greyColor = Color(0xFF9ca3af);
  static const Color navyBlueGrey = Color(0xFF111827);
  static const Color lightNavyBlueGrey = Color(0xFF1f2937);
  static const Color blueColor = Color(0xFF3b82f6);
  static const Color purpleColor = Color(0xFF8b5cf6);
  static const Color goldColor = Color(0xFFf59e0b);
  static const Color lightGreyColor = Color(0xFFf3f4f6);
  static const Color darkGreyColor = Color(0xFF6b7280);
  static const Color backgroundColor = Color(0xFF1a1a2e);
  static const Color redColor = Color(0xFFef4444);
  static const Color shareColor = Color(0xFF8b5cf6);
  static const Color commentColor = Color(0xFF3b82f6);
  static const Color followColor = Color(0xFF22c55e);
  static const Color greenColor = Color(0xFF10b981);
  static const Color lightGreenColor = Color(0xFF22c55e);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1a1a2e),
    Color(0xFF16213e),
    Color(0xFF0f3460),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF6366f1),
    Color(0xFF8b5cf6),
    Color(0xFFec4899),
  ];
}