import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Thème centralisé de l'application OtterLock
class AppTheme {
  AppTheme._();

  /// Configuration du thème principal
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light, surface: AppColors.surface),
    textTheme: AppTextStyles.textTheme,
    inputDecorationTheme: AppInputStyles.inputDecorationTheme,
    elevatedButtonTheme: AppButtonStyles.elevatedButtonTheme,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.background, elevation: 0, systemOverlayStyle: SystemUiOverlayStyle.dark),
  );
}

/// Styles de texte centralisés
class AppTextStyles {
  AppTextStyles._();

  // Titres
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Corps de texte
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Labels et boutons
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  // Placeholder
  static const TextStyle placeholder = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Texte sur fond primaire
  static const TextStyle onPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  /// TextTheme complet pour Material
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,
      headlineMedium: h3,
      headlineSmall: h4,
      titleLarge: h3,
      titleMedium: h4,
      titleSmall: label,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: button,
      labelMedium: label,
      labelSmall: labelSmall,
    );
  }
}

/// Styles des champs de saisie
class AppInputStyles {
  AppInputStyles._();

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: AppTextStyles.placeholder,
    labelStyle: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
    border: _border(),
    enabledBorder: _border(),
    focusedBorder: _focusedBorder(),
    errorBorder: _errorBorder(),
    focusedErrorBorder: _errorBorder(),
  );

  static OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1.4),
  );

  static OutlineInputBorder _focusedBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
  );

  static OutlineInputBorder _errorBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.error, width: 1.6),
  );

  /// Décoration personnalisée pour les champs
  static InputDecoration decoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      errorMaxLines: 2,
    );
  }
}

/// Styles des boutons
class AppButtonStyles {
  AppButtonStyles._();

  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTextStyles.button,
    ),
  );

  /// Style pour bouton primaire
  static ButtonStyle primaryButton({double? height}) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 0,
    minimumSize: Size(double.infinity, height ?? 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
  );

  /// Style pour bouton secondaire
  static ButtonStyle secondaryButton({double? height}) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.grey200,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    minimumSize: Size(double.infinity, height ?? 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
  );

  /// Style pour bouton d'erreur
  static ButtonStyle errorButton({double? height}) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 0,
    minimumSize: Size(double.infinity, height ?? 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
  );
}

/// Constantes de design
class AppSizes {
  AppSizes._();

  // Padding & Margin
  static const double paddingXs = 4;
  static const double paddingSm = 8;
  static const double paddingMd = 16;
  static const double paddingLg = 24;
  static const double paddingXl = 32;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // Icon sizes
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // Button heights
  static const double buttonHeightSm = 40;
  static const double buttonHeightMd = 50;
  static const double buttonHeightLg = 56;
}

/// Décoration de conteneurs réutilisables
class AppDecorations {
  AppDecorations._();

  /// Carte avec ombre
  static BoxDecoration card({Color? color}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
  );

  /// Carte sans ombre
  static BoxDecoration cardFlat({Color? color}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
  );

  /// Conteneur avec bordure
  static BoxDecoration bordered({Color? color, Color? borderColor}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    border: Border.all(color: borderColor ?? AppColors.borderLight),
  );
}
