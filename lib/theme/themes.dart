import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Professional Theme System for EthioConnect
/// Centralized theme management with Material 3 design
class AppThemes {
  /// Light Theme Configuration
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryVariant,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.lightTextPrimary,
      onBackground: AppColors.lightTextPrimary,
      onError: AppColors.white,
      outline: AppColors.lightBorder,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey100,
      hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 2,
      shadowColor: AppColors.lightShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
  );
  
  /// Dark Theme Configuration
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryVariant,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.black,
      onSurface: AppColors.darkTextPrimary,
      onBackground: AppColors.darkTextPrimary,
      onError: AppColors.white,
      outline: AppColors.darkBorder,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.grey800,
        disabledForegroundColor: AppColors.grey600,
        elevation: 2,
        shadowColor: AppColors.darkShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey800.withOpacity(0.3),
      hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: AppColors.darkShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
  );
}
