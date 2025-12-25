import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      // カラーパレット設定
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: Colors.white,
        error: AppColors.error,
      ),

      // テキスト設定 (基本はRoboto, 見出しはOswaldでゴツく)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.oswald(
            fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.oswald(
            fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.bebasNeue(
            fontSize: 30, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.roboto(
            fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.roboto(
            fontSize: 14, color: AppColors.textSecondary),
      ),

      // ボタン設定
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.oswald(fontWeight: FontWeight.bold, fontSize: 18),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // 入力フォーム設定
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
