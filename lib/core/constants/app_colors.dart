import 'package:flutter/material.dart';

/// Palette de couleurs de l'application OtterLock
/// Toutes les couleurs de l'application sont centralisées ici
class AppColors {
  AppColors._();

  // Couleurs de base
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Couleurs principales
  static const Color primary = Color(0xFF1D93F3);
  static const Color primaryPressed = Color(0xFF0F6CC0);
  static const Color primaryDark = Color(0xFF0066CC);
  static const Color primaryLight = Color(0xFF1D93F3);
  
  // Couleurs de fond
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F9FC);
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF42353B);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF42353B);
  
  // Couleurs neutres
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  
  // Couleurs d'état
  static const Color error = Color(0xFFE74C3C);
  static const Color errorDark = Color(0xFFD64545);
  static const Color errorPressed = Color(0xFF7A7A7A);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF1D93F3);
  
  // Couleurs d'overlay
  static const Color overlay = Color(0x66000000);
  static const Color overlayLight = Color(0x1A000000);
  static const Color overlayDark = Color(0x99000000);
  static const Color shadow = Color(0x42000000);
  static const Color shadowLight = Color(0x1A000000);
  
  // Couleurs de bordure
  static const Color border = Color(0xFF104065);
  static const Color borderLight = Color(0xFFE5E7EB);
  
  // Alias pour compatibilité
  static const Color muted = grey500;
  
}
