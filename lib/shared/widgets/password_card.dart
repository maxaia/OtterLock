import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/password_model.dart';
import '../../core/services/password_breach_service.dart';

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
  }

  /// Affiche le dialog d'avertissement de fuite
  void _showLeakWarning() {
    final leakCount = widget.password.leakCount;
    final formatted = PasswordBreachService.formatLeakCount(leakCount);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Mot de passe compromis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Ce mot de passe est apparu dans $formatted. Il est fortement recommandé de le changer immédiatement.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onTap?.call();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Modifier', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Widget indicateur de sécurité du mot de passe
  Widget _buildSecurityIndicator() {
    final password = widget.password;
    
    // Non vérifié
    if (!password.isLeakChecked) {
      return const SizedBox.shrink();
    }
    
    // Sécurisé (bouclier vert)
    if (password.isSecure) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, size: 12, color: AppColors.success),
            SizedBox(width: 4),
            Text(
              'Sécurisé',
              style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    
    // Compromis (bouton d'avertissement)
    return GestureDetector(
      onTap: _showLeakWarning,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Text(
              PasswordBreachService.formatLeakCount(password.leakCount),
              style: const TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMd)),
            ),
            child: Row(
              children: [
                Icon(_categoryIcon, color: AppColors.textOnPrimary, size: 20),
                const SizedBox(width: AppSizes.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.password.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      if (widget.password.isExpired || widget.password.isTemporary) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              widget.password.isExpired ? Icons.warning_amber : Icons.schedule,
                              size: 12,
                              color: AppColors.textOnPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.password.isExpired ? 'Expiré' : 'Temporaire',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: AppColors.textOnPrimary),
                  onPressed: widget.onTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Éditer',
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textOnPrimary),
                  onPressed: widget.onDelete != null ? () => widget.onDelete!() : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusMd)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.password.title, 
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    _buildSecurityIndicator(),
                  ],
                ),
                if (widget.password.url.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.password.url,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (widget.password.isTemporary && widget.password.expirationDate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Expire le ${widget.password.expirationDate!.day.toString().padLeft(2, '0')}/${widget.password.expirationDate!.month.toString().padLeft(2, '0')}/${widget.password.expirationDate!.year} ${widget.password.expirationDate!.hour.toString().padLeft(2, '0')}:${widget.password.expirationDate!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.spacingSm),
                _buildRow(context, 'Identifiant', widget.password.username, true),
                const SizedBox(height: AppSizes.spacingSm),
                _buildRow(context, 'Mot de passe', _showPassword ? widget.password.password : '•' * widget.password.password.length, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, bool showCopy) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label, 
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!showCopy)
          IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility, 
              size: 16, 
              color: AppColors.textSecondary(context),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        IconButton(
          icon: Icon(Icons.copy, size: 16, color: AppColors.textSecondary(context)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _copy(showCopy ? widget.password.username : widget.password.password, label),
        ),
      ],
    );
  }
}
