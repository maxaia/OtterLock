import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Thème centralisé de l'application OtterLock
class AppTheme {
  const AppTheme._();

  /// Configuration du thème clair
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
      primary: AppColors.primary,
    ),
    textTheme: AppTextStyles.textTheme(Brightness.light),
    inputDecorationTheme: AppInputStyles.inputDecorationTheme(Brightness.light),
    elevatedButtonTheme: AppButtonStyles.elevatedButtonTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textOnPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.grey400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.grey300;
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  /// Configuration du thème sombre
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      primary: AppColors.primary,
    ),
    textTheme: AppTextStyles.textTheme(Brightness.dark),
    inputDecorationTheme: AppInputStyles.inputDecorationTheme(Brightness.dark),
    elevatedButtonTheme: AppButtonStyles.elevatedButtonTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textOnPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.grey600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.grey700;
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}

/// Styles de texte centralisés
class AppTextStyles {
  const AppTextStyles._();

  // Couleurs de texte selon le thème
  static Color _textPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  
  static Color _textSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  // Titres
  static TextStyle h1([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: _textPrimary(brightness),
    letterSpacing: -0.5,
  );

  static TextStyle h2([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: _textPrimary(brightness),
    letterSpacing: -0.5,
  );

  static TextStyle h3([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: _textPrimary(brightness),
  );

  static TextStyle h4([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _textPrimary(brightness),
  );

  // Corps de texte
  static TextStyle bodyLarge([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: _textPrimary(brightness),
    height: 1.5,
  );

  static TextStyle bodyMedium([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _textPrimary(brightness),
    height: 1.5,
  );

  static TextStyle bodySmall([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _textSecondary(brightness),
    height: 1.4,
  );

  // Labels et boutons
  static TextStyle label([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _textPrimary(brightness),
  );

  static TextStyle labelSmall([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _textPrimary(brightness),
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
  static TextStyle placeholder([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: _textSecondary(brightness),
  );

  // Caption
  static TextStyle caption([Brightness brightness = Brightness.light]) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _textSecondary(brightness),
  );

  // Texte sur fond primaire
  static const TextStyle onPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  /// TextTheme complet pour Material
  static TextTheme textTheme([Brightness brightness = Brightness.light]) {
    return TextTheme(
      displayLarge: h1(brightness),
      displayMedium: h2(brightness),
      displaySmall: h3(brightness),
      headlineMedium: h3(brightness),
      headlineSmall: h4(brightness),
      titleLarge: h3(brightness),
      titleMedium: h4(brightness),
      titleSmall: label(brightness),
      bodyLarge: bodyLarge(brightness),
      bodyMedium: bodyMedium(brightness),
      bodySmall: bodySmall(brightness),
      labelLarge: button,
      labelMedium: label(brightness),
      labelSmall: labelSmall(brightness),
    );
  }
}

/// Styles des champs de saisie
class AppInputStyles {
  const AppInputStyles._();

  static InputDecorationTheme inputDecorationTheme([Brightness brightness = Brightness.light]) {
    final isDark = brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.placeholder(brightness),
      labelStyle: AppTextStyles.label(brightness).copyWith(
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
      border: _border(borderColor),
      enabledBorder: _border(borderColor),
      focusedBorder: _focusedBorder(),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _errorBorder(),
    );
  }

  static OutlineInputBorder _border(Color borderColor) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: borderColor, width: 1.4),
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
  const AppButtonStyles._();

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
    foregroundColor: AppColors.lightTextPrimary,
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
  const AppSizes._();

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
  const AppDecorations._();

  /// Carte avec ombre (adapté au thème)
  static BoxDecoration card(BuildContext context) => BoxDecoration(
    color: AppColors.cardBackground(context),
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    boxShadow: [
      BoxShadow(
        color: AppColors.isDark(context) 
            ? Colors.black.withValues(alpha: 0.3) 
            : AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Carte sans ombre (adapté au thème)
  static BoxDecoration cardFlat(BuildContext context) => BoxDecoration(
    color: AppColors.cardBackground(context),
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
  );

  /// Conteneur avec bordure (adapté au thème)
  static BoxDecoration bordered(BuildContext context, {Color? color, Color? borderColor}) => BoxDecoration(
    color: color ?? AppColors.cardBackground(context),
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    border: Border.all(color: borderColor ?? AppColors.border(context)),
  );
}
