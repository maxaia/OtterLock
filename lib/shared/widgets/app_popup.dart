import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Types de popup disponibles
enum PopupType {
  success,
  error,
  lockout,
}

/// Widget de popup réutilisable pour l'application
/// Design minimaliste et moderne pour une meilleure UX
class AppPopup extends StatelessWidget {
  final PopupType type;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const AppPopup({
    super.key,
    required this.type,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });

  /// Affiche une popup de succès (PIN enregistré)
  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    required VoidCallback onContinue,
  }) {
    return _showPopup(
      context,
      type: PopupType.success,
      message: message,
      buttonText: 'Continuer',
      onButtonPressed: onContinue,
    );
  }

  /// Affiche une popup d'erreur (PIN différent)
  static Future<void> showError(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return _showPopup(
      context,
      type: PopupType.error,
      message: message,
      buttonText: 'Réessayer',
      onButtonPressed: onRetry,
    );
  }

  /// Affiche une popup de verrouillage (5 tentatives échouées)
  static Future<void> showLockout(
    BuildContext context, {
    required String message,
    required VoidCallback onClose,
  }) {
    return _showPopup(
      context,
      type: PopupType.lockout,
      message: message,
      buttonText: 'Compris',
      onButtonPressed: onClose,
      barrierDismissible: false,
    );
  }

  static Future<void> _showPopup(
    BuildContext context, {
    required PopupType type,
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => Center(
        child: AppPopup(
          type: type,
          message: message,
          buttonText: buttonText,
          onButtonPressed: () {
            Navigator.of(context).pop();
            onButtonPressed();
          },
        ),
      ),
    );
  }

  Color get _primaryColor {
    switch (type) {
      case PopupType.success:
        return AppColors.primary;
      case PopupType.error:
        return AppColors.error;
      case PopupType.lockout:
        return AppColors.errorDark;
    }
  }

  IconData get _icon {
    switch (type) {
      case PopupType.success:
        return Icons.check_circle_rounded;
      case PopupType.error:
        return Icons.error_rounded;
      case PopupType.lockout:
        return Icons.lock_clock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: _primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Button
            _PopupButton(
              text: buttonText,
              color: _primaryColor,
              onPressed: onButtonPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _PopupButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_PopupButton> createState() => _PopupButtonState();
}

class _PopupButtonState extends State<_PopupButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: _isPressed ? widget.color.withOpacity(0.85) : widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
