import 'package:flutter/material.dart';

/// Palette de couleurs de l'application OtterLock
/// Toutes les couleurs de l'application sont centralisées ici
/// Support du mode clair et sombre
class AppColors {
  const AppColors._();

  // ===== COULEURS STATIQUES (ne changent pas avec le thème) =====
  
  // Couleurs de base
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Couleurs principales (identiques pour les deux thèmes)
  static const Color primary = Color(0xFF1D93F3);
  static const Color primaryPressed = Color(0xFF0F6CC0);
  static const Color primaryDark = Color(0xFF0066CC);
  static const Color primaryLight = Color(0xFF4DA8F7);

  // Couleurs d'état (identiques pour les deux thèmes)
  static const Color error = Color(0xFFE74C3C);
  static const Color errorDark = Color(0xFFD64545);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF1D93F3);

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

  // Couleurs d'overlay
  static const Color overlay = Color(0x66000000);
  static const Color overlayLight = Color(0x1A000000);
  static const Color overlayDark = Color(0x99000000);
  static const Color shadow = Color(0x42000000);
  static const Color shadowLight = Color(0x1A000000);

  // Texte sur fond primaire (toujours blanc)
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Alias pour compatibilité
  static const Color muted = grey500;

  // ===== COULEURS THÈME CLAIR =====
  static const Color lightBackground = Color(0xFFF7F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF7F9FC);
  static const Color lightTextPrimary = Color(0xFF42353B);
  static const Color lightTextSecondary = Color(0xFF9A9A9A);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSearchBackground = Color(0xFFFFFFFF);
  static const Color lightInputBackground = Color(0xFFFFFFFF);

  // ===== COULEURS THÈME SOMBRE =====
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF252525);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkSearchBackground = Color(0xFF2A2A2A);
  static const Color darkInputBackground = Color(0xFF2A2A2A);

  // ===== MÉTHODES POUR OBTENIR LES COULEURS SELON LE THÈME =====
  
  /// Couleur de fond principale
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;

  /// Couleur de surface (cartes, conteneurs)
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;

  /// Couleur de surface variante
  static Color surfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceVariant : lightSurfaceVariant;

  /// Couleur de texte principale
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  /// Couleur de texte secondaire
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  /// Couleur de bordure
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;

  /// Couleur de fond des cartes
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardBackground : lightCardBackground;

  /// Couleur de fond de la barre de recherche
  static Color searchBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSearchBackground : lightSearchBackground;

  /// Couleur de fond des champs de saisie
  static Color inputBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkInputBackground : lightInputBackground;

  /// Vérifie si le thème actuel est sombre
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
