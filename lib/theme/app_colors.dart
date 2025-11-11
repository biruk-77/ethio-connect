import 'package:flutter/material.dart';

/// Centralized Color Palette for EthioConnect
/// Professional theme system with semantic color naming
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryVariant = Color(0xFFF57C00);
  
  // Ethiopian Flag Colors
  static const Color ethiopianGreen = Color(0xFF009639);
  static const Color ethiopianYellow = Color(0xFFFEDF00);
  static const Color ethiopianRed = Color(0xFFDA020E);
  
  // Status & Feedback Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // Grey Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1A000000);
  
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextTertiary = Color(0xFF9E9E9E);
  static const Color lightTextDisabled = Color(0xFFBDBDBD);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkShadow = Color(0x33000000);
  
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF757575);
  static const Color darkTextDisabled = Color(0xFF616161);
  
  // Specialized Colors
  static const Color premium = Color(0xFFFFD700);
  static const Color verified = Color(0xFF1DA1F2);
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color away = Color(0xFFFF9800);
  static const Color busy = Color(0xFFF44336);
  
  // Overlay Colors
  static const Color overlayLight = Color(0x33000000);
  static const Color overlayDark = Color(0x66000000);
  static const Color scrim = Color(0x99000000);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient ethiopianGradient = LinearGradient(
    colors: [ethiopianGreen, ethiopianYellow, ethiopianRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
