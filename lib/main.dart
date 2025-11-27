import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const OtterLockApp());
}

class OtterLockApp extends StatelessWidget {
  const OtterLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtterLock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _AppColors.primary,
          brightness: Brightness.light,
          background: _AppColors.background,
        ),
        textTheme: ThemeData.light()
            .textTheme
            .apply(bodyColor: _AppColors.primary, displayColor: _AppColors.primary),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _AppColors.primary, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: _AppColors.primary.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _AppColors.primary, width: 1.6),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  Timer? _hideTimer;
  bool _showLastChar = false;

  @override
  void dispose() {
    _pinController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _handleKey(String value) {
    if (value == '←') {
      if (_pinController.text.isEmpty) return;
      _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
      _hideTimer?.cancel();
      setState(() {
        _showLastChar = false;
      });
      return;
    }

    if (value == '→') {
      _submit();
      return;
    }

    if (_pinController.text.length >= 6) return;

    _pinController.text += value;
    _hideTimer?.cancel();
    setState(() {
      _showLastChar = true;
    });

    _hideTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showLastChar = false;
        });
      }
    });
  }

  void _submit() {
    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le code PIN doit contenir au moins 4 chiffres')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Authentification en cours...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compactHeight = constraints.maxHeight < 760;
            final double sidePadding = compactHeight ? 20 : 28;
            final double verticalGap = compactHeight ? 14 : 22;
            final double titleSize = compactHeight ? 28 : 34;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: viewInsets > 0 ? viewInsets * 0.6 : 0),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: verticalGap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Entrer le code PIN',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              color: _AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: titleSize,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                  color: Colors.black.withOpacity(0.15),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: verticalGap * 0.5),
                          Text(
                            'Votre code PIN contient au moins 4 chiffres.',
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: _AppColors.primary.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                              fontSize: compactHeight ? 15 : 18,
                            ),
                          ),
                          SizedBox(height: verticalGap),
                          _buildPinDisplay(compactHeight),
                          SizedBox(height: verticalGap),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom:50),
                                child: _buildKeypad(compact: compactHeight),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPinDisplay(bool compact) {
    return SizedBox(
      height: compact ? 50 : 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pinController.text.length, (index) {
          final bool isLast = index == _pinController.text.length - 1;
          final bool showChar = isLast && _showLastChar;
          final String char = _pinController.text[index];

          return Container(
            width: 40,
            alignment: Alignment.center,
            child: showChar
                ? Text(
                    char,
                    style: TextStyle(
                      color: _AppColors.primary,
                      fontSize: compact ? 30 : 36,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: _AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
          );
        }),
      ),
    );
  }

  Widget _buildKeypad({required bool compact}) {
    Widget buildRow(List<String> values) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _KeypadButton(label: values[0], onTap: () => _handleKey(values[0])),
          const SizedBox(width: 32),
          _KeypadButton(label: values[1], onTap: () => _handleKey(values[1])),
          const SizedBox(width: 32),
          _KeypadButton(label: values[2], onTap: () => _handleKey(values[2])),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildRow(['1', '2', '3']),
        const SizedBox(height: 20),
        buildRow(['4', '5', '6']),
        const SizedBox(height: 20),
        buildRow(['7', '8', '9']),
        const SizedBox(height: 20),
        buildRow(['←', '0', '→']),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDelete = label == '←';
    final bool isSubmit = label == '→';

    Color bgColor = Colors.white;
    Widget content;

    if (isDelete) {
      bgColor = const Color(0xFF9A9A9A);
      content = const Icon(Icons.close, color: Colors.white, size: 28);
    } else if (isSubmit) {
      bgColor = const Color(0xFF1D93F3);
      content = const Icon(Icons.arrow_forward, color: Colors.white, size: 28);
    } else {
      content = Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF42353B),
          fontSize: 28,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

class _AppColors {
  static const Color primary = Color(0xFF1D93F3);
  static const Color muted = Color(0xFF9A9A9A);
  static const Color background = Color(0xFFF7F9FC);
}
