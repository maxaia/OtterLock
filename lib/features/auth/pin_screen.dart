import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/pin_service.dart';
import '../../shared/widgets/widgets.dart';
import '../home/home_screen.dart';

/// États possibles de l'écran PIN
enum PinScreenState {
  loading,
  createPin,
  confirmPin,
  enterPin,
  lockedOut,
}

/// Écran de saisie/création du code PIN
class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final PinService _pinService = PinService();
  
  String _currentPin = '';
  String? _firstPin;
  Timer? _hideTimer;
  bool _showLastChar = false;
  bool _isSubmitting = false;
  PinScreenState _state = PinScreenState.loading;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  /// Initialise l'écran selon l'état du PIN
  Future<void> _initializeScreen() async {
    // Vérifier si l'utilisateur est verrouillé
    if (await _pinService.isLockedOut()) {
      setState(() => _state = PinScreenState.lockedOut);
      _showLockoutPopup();
      return;
    }

    // Vérifier si un PIN existe déjà
    final hasPinRegistered = await _pinService.hasPinRegistered();
    setState(() {
      _state = hasPinRegistered ? PinScreenState.enterPin : PinScreenState.createPin;
    });
  }

  /// Affiche la popup de verrouillage
  Future<void> _showLockoutPopup() async {
    if (!mounted) return;
    
    await AppPopup.showLockout(
      context,
      message: 'Code PIN incorrect sur 5 reprises.\nTentatives bloquées pendant 5 minutes',
      onClose: () {
        // Vérifier à nouveau si le verrouillage est terminé
        _initializeScreen();
      },
    );
  }

  /// Gère l'appui sur une touche du clavier
  void _handleKey(String value) {
    if (_isSubmitting) return;

    if (value == '←') {
      _handleDelete();
    } else if (value == '→') {
      _handleSubmit();
    } else if (value == '↩') {
      _handleBack();
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

  /// Retourne à l'étape précédente (confirmation → création)
  void _handleBack() {
    if (_state == PinScreenState.confirmPin) {
      setState(() {
        _state = PinScreenState.createPin;
        _currentPin = '';
        _firstPin = null;
        _showLastChar = false;
      });
    }
  }

  /// Soumet le PIN
  Future<void> _handleSubmit() async {
    if (_currentPin.length < AppConstants.minPinLength || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      switch (_state) {
        case PinScreenState.createPin:
          await _handleCreatePin();
          break;
        case PinScreenState.confirmPin:
          await _handleConfirmPin();
          break;
        case PinScreenState.enterPin:
          await _handleVerifyPin();
          break;
        default:
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Gère la création du PIN (première saisie)
  Future<void> _handleCreatePin() async {
    _firstPin = _currentPin;
    setState(() {
      _state = PinScreenState.confirmPin;
      _currentPin = '';
      _showLastChar = false;
    });
  }

  /// Gère la confirmation du PIN
  Future<void> _handleConfirmPin() async {
    if (_currentPin == _firstPin) {
      // PIN confirmé, on l'enregistre
      await _pinService.savePin(_currentPin);
      
      if (!mounted) return;
      
      await AppPopup.showSuccess(
        context,
        message: 'Code PIN enregistré avec succès !',
        onContinue: () {
          setState(() {
            _state = PinScreenState.enterPin;
            _currentPin = '';
            _firstPin = null;
            _showLastChar = false;
          });
        },
      );
    } else {
      // Les PIN ne correspondent pas
      if (!mounted) return;
      
      await AppPopup.showError(
        context,
        message: 'Code PIN différent du premier, veuillez le ressaisir.',
        onRetry: () {
          setState(() {
            _state = PinScreenState.createPin;
            _currentPin = '';
            _firstPin = null;
            _showLastChar = false;
          });
        },
      );
    }
  }

  /// Gère la vérification du PIN
  Future<void> _handleVerifyPin() async {
    // Vérifier si l'utilisateur est verrouillé
    if (await _pinService.isLockedOut()) {
      setState(() {
        _state = PinScreenState.lockedOut;
        _currentPin = '';
      });
      _showLockoutPopup();
      return;
    }

    final isCorrect = await _pinService.verifyPin(_currentPin);
    
    if (isCorrect) {
      await _pinService.resetFailedAttempts();
      
      if (!mounted) return;
      
      // Navigation vers l'écran principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      final failedAttempts = await _pinService.incrementFailedAttempts();
      
      if (!mounted) return;
      
      // Effacer le PIN
      setState(() {
        _currentPin = '';
        _showLastChar = false;
      });
      
      // Vérifier si on atteint le maximum de tentatives
      if (failedAttempts >= AppConstants.maxFailedAttempts) {
        setState(() => _state = PinScreenState.lockedOut);
        _showLockoutPopup();
      } else {
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Code PIN incorrect (${failedAttempts}/${AppConstants.maxFailedAttempts} tentatives)',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Titre selon l'état actuel
  String get _title {
    switch (_state) {
      case PinScreenState.createPin:
        return 'Créer un code PIN';
      case PinScreenState.confirmPin:
        return 'Confirmer le code PIN';
      case PinScreenState.enterPin:
        return 'Entrer le code PIN';
      case PinScreenState.lockedOut:
        return 'Accès bloqué';
      default:
        return '';
    }
  }

  /// Sous-titre selon l'état actuel
  String get _subtitle {
    switch (_state) {
      case PinScreenState.createPin:
        return 'Créez un code PIN pour sécuriser votre application.';
      case PinScreenState.confirmPin:
        return 'Veuillez saisir à nouveau votre code PIN.';
      case PinScreenState.enterPin:
        return 'Votre code PIN contient au moins 4 chiffres.';
      case PinScreenState.lockedOut:
        return 'Veuillez patienter avant de réessayer.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == PinScreenState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool showBackArrow = _state == PinScreenState.confirmPin;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compactHeight = constraints.maxHeight < 760;
            final double sidePadding = compactHeight ? 20 : 28;
            final double verticalGap = compactHeight ? 14 : 22;
            final double titleSize = compactHeight ? 28 : 34;

            return Column(
              children: [
                // Back arrow header
                if (showBackArrow)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _handleBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: Colors.black26,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePadding,
                      vertical: verticalGap,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: showBackArrow ? 20 : 60),
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
                                color: Colors.black.withOpacity(0.15),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: verticalGap * 0.5),
                        Text(
                          _subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                            fontSize: compactHeight ? 15 : 18,
                          ),
                        ),
                        SizedBox(height: verticalGap),
                        PinDisplay(
                          pin: _currentPin,
                          showLastChar: _showLastChar,
                          compact: compactHeight,
                        ),
                        SizedBox(height: verticalGap),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 50),
                              child: _buildKeypad(compactHeight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
