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

  Color get _defaultColor {
    if (_isDelete) return AppColors.muted;
    if (_isSubmit) return AppColors.primary;
    return AppColors.white;
  }

  Color get _pressedColor {
    if (_isDelete) return const Color(0xFF7A7A7A);
    return AppColors.primaryPressed;
  }

  Color get _currentColor {
    if (!widget.enabled && _isSubmit) {
      return AppColors.muted;
    }
    return _isPressed ? _pressedColor : _defaultColor;
  }

  Widget get _content {
    if (_isDelete) {
      return const Icon(Icons.close, color: Colors.white, size: 28);
    }
    if (_isSubmit) {
      return const Icon(Icons.arrow_forward, color: Colors.white, size: 28);
    }
    return Text(
      widget.label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _isPressed ? Colors.white : AppColors.textDark,
        fontSize: 28,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
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
          color: _currentColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        alignment: Alignment.center,
        child: _content,
      ),
    );
  }
}
