import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'features/splash/splash_screen.dart';

/// Instance globale du service de thème
final ThemeService themeService = ThemeService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser le service de thème
  await themeService.init();
  
  // Définir le style de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const OtterLockApp());
}

class OtterLockApp extends StatefulWidget {
  const OtterLockApp({super.key});

  @override
  State<OtterLockApp> createState() => _OtterLockAppState();
}

class _OtterLockAppState extends State<OtterLockApp> {
  @override
  void initState() {
    super.initState();
    themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtterLock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: const SplashScreen(),
    );
  }
}

