import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Dialog de succès avec animation
class SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onContinue;
  final String? buttonText;

  const SuccessDialog({
    super.key,
    this.title = 'Succès !',
    this.message = 'L\'opération a été effectuée avec succès.',
    required this.onContinue,
    this.buttonText,
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône animée
              ScaleTransition(
                scale: _bounceAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded, size: 40, color: AppColors.success),
                ),
              ),
              const SizedBox(height: AppSizes.spacingLg),
              
              // Titre
              Text(
                widget.title,
                style: AppTextStyles.h3().copyWith(color: AppColors.success),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingSm),
              
              // Message
              Text(
                widget.message,
                style: AppTextStyles.bodyMedium(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingLg),
              
              // Bouton
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightMd,
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  style: AppButtonStyles.primaryButton(),
                  child: Text(widget.buttonText ?? 'Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog de confirmation
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        decoration: AppDecorations.card(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(isDestructive ? Icons.warning_rounded : Icons.help_rounded, size: 32, color: color),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            Text(title, style: AppTextStyles.h4(), textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.spacingSm),
            Text(message, style: AppTextStyles.bodyMedium(), textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.spacingLg),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightMd,
                    child: ElevatedButton(
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      style: AppButtonStyles.secondaryButton(),
                      child: Text(cancelText ?? 'Annuler'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMd),
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightMd,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: isDestructive ? AppButtonStyles.errorButton() : AppButtonStyles.primaryButton(),
                      child: Text(confirmText ?? 'Confirmer'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog d'information simple
class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;
  final String? buttonText;
  final IconData? icon;

  const InfoDialog({super.key, required this.title, required this.message, this.onClose, this.buttonText, this.icon});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        decoration: AppDecorations.card(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: AppSizes.spacingMd),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingLg),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightMd,
              child: ElevatedButton(
                onPressed: onClose ?? () => Navigator.of(context).pop(),
                style: AppButtonStyles.primaryButton(),
                child: Text(buttonText ?? 'Compris'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
