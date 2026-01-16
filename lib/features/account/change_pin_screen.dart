import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/keypad_button.dart';
import '../../shared/widgets/pin_display.dart';
import '../../shared/widgets/app_popup.dart';
import '../../core/services/pin_service.dart';

/// États possibles de l'écran de changement de mot de passe
enum ChangePasswordState {
  enterCurrent,
  createNew,
  confirmNew,
}

/// Écran de changement du mot de passe maître
class ChangeMasterPasswordScreen extends StatefulWidget {
  const ChangeMasterPasswordScreen({super.key});

  @override
  State<ChangeMasterPasswordScreen> createState() => _ChangeMasterPasswordScreenState();
}

class _ChangeMasterPasswordScreenState extends State<ChangeMasterPasswordScreen> with SingleTickerProviderStateMixin {
  final PinService _pinService = PinService();
  
  String _currentPin = '';
  String? _newPin;
  Timer? _hideTimer;
  bool _showLastChar = false;
  bool _isSubmitting = false;
  ChangePasswordState _state = ChangePasswordState.enterCurrent;
  String? _errorMessage;
  Timer? _errorTimer;
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(
      CurveTween(curve: Curves.easeInOut),
    ).animate(_shakeController);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _errorTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  /// Gère l'appui sur une touche du clavier
  void _handleKey(String value) {
    if (_isSubmitting) return;

    if (value == '←') {
      _handleDelete();
    } else if (value == '→') {
      _handleSubmit();
    } else {
      _handleDigit(value);
    }
  }

  /// Supprime le dernier caractère
  void _handleDelete() {
    if (_currentPin.isEmpty) return;
    
    _hideTimer?.cancel();
    setState(() {
      _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      _showLastChar = false;
    });
  }

  /// Ajoute un chiffre au PIN
  void _handleDigit(String digit) {
    if (_currentPin.length >= AppConstants.maxPinLength) return;

    _hideTimer?.cancel();
    setState(() {
      _currentPin += digit;
      _showLastChar = true;
    });

    _hideTimer = Timer(
      const Duration(milliseconds: AppConstants.pinCharDisplayDurationMs),
      () {
        if (mounted) {
          setState(() => _showLastChar = false);
        }
      },
    );
  }

  /// Soumet le PIN
  Future<void> _handleSubmit() async {
    if (_currentPin.length < AppConstants.minPinLength || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      switch (_state) {
        case ChangePasswordState.enterCurrent:
          await _handleVerifyCurrent();
          break;
        case ChangePasswordState.createNew:
          await _handleCreateNew();
          break;
        case ChangePasswordState.confirmNew:
          await _handleConfirmNew();
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Vérifie le mot de passe actuel
  Future<void> _handleVerifyCurrent() async {
    final isCorrect = await _pinService.verifyPin(_currentPin);
    
    if (isCorrect) {
      setState(() {
        _state = ChangePasswordState.createNew;
        _currentPin = '';
        _showLastChar = false;
      });
    } else {
      if (!mounted) return;
      
      // Vibrer et animer
      await HapticFeedback.heavyImpact();
      await _shakeController.forward();
      await _shakeController.reverse();
      
      if (!mounted) return;
      
      _errorTimer?.cancel();
      setState(() {
        _currentPin = '';
        _showLastChar = false;
        _errorMessage = 'Code incorrect';
      });
      
      _errorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    }
  }

  /// Gère la création du nouveau PIN
  Future<void> _handleCreateNew() async {
    _newPin = _currentPin;
    setState(() {
      _state = ChangePasswordState.confirmNew;
      _currentPin = '';
      _showLastChar = false;
    });
  }

  /// Gère la confirmation du nouveau PIN
  Future<void> _handleConfirmNew() async {
    if (_currentPin == _newPin) {
      // PIN confirmé, on l'enregistre
      await _pinService.savePin(_currentPin);
      
      if (!mounted) return;
      
      await AppPopup.showSuccess(
        context,
        message: 'Mot de passe modifié avec succès !',
        onContinue: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      // Les PIN ne correspondent pas
      if (!mounted) return;
      
      // Vibrer et animer
      await HapticFeedback.heavyImpact();
      await _shakeController.forward();
      await _shakeController.reverse();
      
      if (!mounted) return;
      
      _errorTimer?.cancel();
      setState(() {
        _currentPin = '';
        _showLastChar = false;
        _errorMessage = 'Les codes ne correspondent pas';
      });
      
      _errorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _state = ChangePasswordState.createNew;
            _errorMessage = null;
            _newPin = null;
          });
        }
      });
    }
  }

  /// Titre selon l'état actuel
  String get _title {
    switch (_state) {
      case ChangePasswordState.enterCurrent:
        return 'Code actuel';
      case ChangePasswordState.createNew:
        return 'Nouveau code';
      case ChangePasswordState.confirmNew:
        return 'Confirmer le code';
    }
  }

  /// Sous-titre selon l'état actuel
  String get _subtitle {
    switch (_state) {
      case ChangePasswordState.enterCurrent:
        return 'Entrez votre code PIN actuel';
      case ChangePasswordState.createNew:
        return 'Créez un nouveau code PIN';
      case ChangePasswordState.confirmNew:
        return 'Confirmez votre nouveau code PIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Changer le mot de passe',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compactHeight = constraints.maxHeight < 760;
            final double sidePadding = compactHeight ? 20 : 28;
            final double verticalGap = compactHeight ? 14 : 22;
            final double titleSize = compactHeight ? 24 : 28;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sidePadding,
                vertical: verticalGap,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: verticalGap),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: titleSize,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: verticalGap * 0.5),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w500,
                      fontSize: compactHeight ? 15 : 18,
                    ),
                  ),
                  SizedBox(height: verticalGap),
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_shakeAnimation.value * ((_currentPin.length % 2 == 0) ? 1 : -1), 0),
                      child: child,
                    ),
                    child: PinDisplay(
                      pin: _currentPin,
                      showLastChar: _showLastChar,
                      compact: compactHeight,
                    ),
                  ),
                  // Message d'erreur
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _errorMessage != null
                        ? Padding(
                            key: ValueKey(_errorMessage),
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(key: ValueKey('empty'), height: 16),
                  ),
                  SizedBox(height: verticalGap * 0.3),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildKeypad(compactHeight),
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

  Widget _buildKeypad(bool compact) {
    Widget buildRow(List<String> values) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: values.map((value) {
          final bool isSubmitButton = value == '→';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: KeypadButton(
              label: value,
              onTap: () => _handleKey(value),
              enabled: !_isSubmitting || !isSubmitButton,
            ),
          );
        }).toList(),
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
