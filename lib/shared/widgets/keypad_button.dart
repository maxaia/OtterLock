import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Bouton du clavier numérique avec effet de pression
class KeypadButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const KeypadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<KeypadButton> {
  bool _isPressed = false;

  bool get _isDelete => widget.label == '←';
  bool get _isSubmit => widget.label == '→';

  Color _defaultColor(BuildContext context) {
    if (_isDelete) return AppColors.muted;
    if (_isSubmit) return AppColors.primary;
    return AppColors.cardBackground(context);
  }

  Color get _pressedColor {
    if (_isDelete) return AppColors.grey600;
    return AppColors.primaryPressed;
  }

  Color _currentColor(BuildContext context) {
    if (!widget.enabled && _isSubmit) return AppColors.muted;
    return _isPressed ? _pressedColor : _defaultColor(context);
  }

  Widget _content(BuildContext context) {
    if (_isDelete) {
      return const Icon(Icons.close, color: AppColors.textOnPrimary, size: 28);
    }
    if (_isSubmit) {
      return const Icon(Icons.arrow_forward, color: AppColors.textOnPrimary, size: 28);
    }
    return Text(
      widget.label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _isPressed ? AppColors.textOnPrimary : AppColors.textPrimary(context),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _currentColor(context),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.isDark(context) 
                  ? Colors.black.withValues(alpha: 0.4) 
                  : AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 4),
            )
          ],
        ),
        alignment: Alignment.center,
        child: _content(context),
      ),
    );
  }
}
