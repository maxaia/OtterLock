import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Bouton primaire réutilisable avec animations
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isError;
  final double? height;
  final Widget? icon;
  final bool animate;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isError = false,
    this.height,
    this.icon,
    this.animate = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && widget.animate) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.animate) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.animate) {
      _controller.reverse();
    }
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    if (widget.isError) return AppButtonStyles.errorButton(height: widget.height);
    if (widget.isSecondary) {
      // Style adapté au dark mode
      return ElevatedButton.styleFrom(
        backgroundColor: AppColors.isDark(context) ? AppColors.grey700 : AppColors.grey200,
        foregroundColor: AppColors.isDark(context) ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        minimumSize: Size(double.infinity, widget.height ?? 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button,
      );
    }
    return AppButtonStyles.primaryButton(height: widget.height);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          height: widget.height ?? AppSizes.buttonHeightMd,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: _getButtonStyle(context),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, 
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                    ),
                  )
                : widget.icon != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.icon!,
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.text,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      )
                    : Text(widget.text),
          ),
        ),
      ),
    );
  }
}

/// Champ de saisie réutilisable
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final void Function(String)? onChanged;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          cursorColor: AppColors.primary,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: AppColors.inputBackground(context),
            hintStyle: TextStyle(color: AppColors.textSecondary(context)),
            labelStyle: TextStyle(color: AppColors.textSecondary(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            enabledBorder: hasError 
                ? const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.error, width: 1.6),
                  )
                : OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
            focusedBorder: hasError
                ? const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.error, width: 1.6),
                  )
                : const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.6),
                  ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Carte réutilisable avec gestion des états pressed
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool withShadow;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.withShadow = true,
    this.color,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding ?? const EdgeInsets.all(AppSizes.paddingMd),
        decoration: widget.withShadow
            ? AppDecorations.card(context).copyWith(
                color: _isPressed 
                    ? (widget.color ?? AppColors.cardBackground(context)).withValues(alpha: 0.9)
                    : widget.color ?? AppColors.cardBackground(context),
              )
            : AppDecorations.cardFlat(context).copyWith(
                color: _isPressed 
                    ? (widget.color ?? AppColors.cardBackground(context)).withValues(alpha: 0.9)
                    : widget.color ?? AppColors.cardBackground(context),
              ),
        child: widget.child,
      ),
    );
  }
}

/// Conteneur de section avec label
class AppSection extends StatelessWidget {
  final String label;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppSection({super.key, required this.label, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label, 
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
      const SizedBox(height: AppSizes.spacingSm),
      child,
    ],
  );
}

/// Icône avec badge de notification
class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color? iconColor;
  final double size;

  const AppIconBadge({
    super.key,
    required this.icon,
    this.count,
    this.iconColor,
    this.size = AppSizes.iconMd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: iconColor ?? AppColors.primary, size: size),
        if (count != null && count! > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count! > 9 ? '9+' : count.toString(),
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Bouton iconique circulaire
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = AppSizes.iconMd,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
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
      child: Icon(
        widget.icon,
        size: widget.size,
        color: widget.color ?? AppColors.textOnPrimary,
      ),
    );
  }
}

/// Divider personnalisé
class AppDivider extends StatelessWidget {
  final double? height;
  final Color? color;

  const AppDivider({super.key, this.height, this.color});

  @override
  Widget build(BuildContext context) => Container(
    height: height ?? 1,
    color: color ?? AppColors.border(context),
  );
}

/// Badge de statut
class AppStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isOutlined;

  const AppStatusBadge({super.key, required this.text, required this.color, this.isOutlined = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      border: isOutlined ? Border.all(color: color) : null,
    ),
    child: Text(
      text, 
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}
