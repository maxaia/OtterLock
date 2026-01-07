import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/password_model.dart';

/// Widget représentant une carte de mot de passe
class PasswordCard extends StatefulWidget {
  final PasswordModel password;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PasswordCard({
    super.key,
    required this.password,
    this.onTap,
    this.onDelete,
  });

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  bool _showPassword = false;

  IconData get _categoryIcon {
    final cat = widget.password.category.toLowerCase();
    return cat.contains('mail') ? Icons.email_outlined
        : cat.contains('réseau') || cat.contains('social') ? Icons.share_outlined
        : cat.contains('travail') ? Icons.work_outline
        : cat.contains('banque') ? Icons.account_balance_outlined
        : Icons.lock_outline;
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copié !'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMd)),
            ),
            child: Row(
              children: [
                Icon(_categoryIcon, color: AppColors.textOnPrimary, size: 20),
                const SizedBox(width: AppSizes.spacingSm),
                Expanded(
                  child: Text(
                    widget.password.category,
                    style: AppTextStyles.label.copyWith(color: AppColors.textOnPrimary),
                  ),
                ),
                if (widget.password.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text('Expiré', style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary)),
                  )
                else if (widget.password.isTemporary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text('Mot de passe temporaire', style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary)),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusMd)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.password.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (widget.password.url.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.password.url,
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary, decoration: TextDecoration.underline),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (widget.password.isTemporary && widget.password.expirationDate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Expire le ${widget.password.expirationDate!.day.toString().padLeft(2, '0')}/${widget.password.expirationDate!.month.toString().padLeft(2, '0')}/${widget.password.expirationDate!.year} ${widget.password.expirationDate!.hour.toString().padLeft(2, '0')}:${widget.password.expirationDate!.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                  ),
                ],
                const SizedBox(height: AppSizes.spacingSm),
                _buildRow('Identifiant', widget.password.username, true),
                const SizedBox(height: AppSizes.spacingSm),
                _buildRow('Mot de passe', _showPassword ? widget.password.password : '•' * widget.password.password.length, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, bool showCopy) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!showCopy)
          IconButton(
            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 16, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16, color: AppColors.textSecondary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _copy(showCopy ? widget.password.username : widget.password.password, label),
        ),
      ],
    );
  }
}
