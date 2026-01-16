import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/password_model.dart';
import '../../core/services/database_service.dart';
import '../../core/services/password_breach_service.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/dialogs.dart';
import '../../shared/widgets/app_popup.dart';
import '../../shared/widgets/password_form_helpers.dart';

/// Écran d'ajout d'un nouveau mot de passe
class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _urlController = TextEditingController();
  final _dummyFocusNode = FocusNode();
  
  PasswordCategory? _selectedCategory;
  bool _isTemporaryPassword = false;
  DateTime? _expirationDate;
  TimeOfDay? _expirationTime;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showCategoryDropdown = false;
  bool _showValidationErrors = false;
  bool _isSaving = false;
  String? _expirationDateTimeError;
  
  String? _passwordStrength;
  Color _passwordStrengthColor = AppColors.muted;
  bool _passwordsMatch = true;
  
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _urlController.dispose();
    _dummyFocusNode.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = null;
        _passwordStrengthColor = AppColors.muted;
      });
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password)) score++;

    setState(() {
      if (score <= 2) {
        _passwordStrength = 'Faible';
        _passwordStrengthColor = AppColors.error;
      } else if (score <= 4) {
        _passwordStrength = 'Moyen';
        _passwordStrengthColor = AppColors.warning;
      } else {
        _passwordStrength = 'Puissant';
        _passwordStrengthColor = AppColors.success;
      }
    });
    _checkPasswordsMatch();
  }

  void _checkPasswordsMatch() {
    setState(() => _passwordsMatch = 
      _confirmPasswordController.text.isEmpty || 
      _passwordController.text == _confirmPasswordController.text);
  }

  void _validateExpirationDateTime() {
    if (!_isTemporaryPassword || _expirationDate == null || _expirationTime == null) {
      setState(() => _expirationDateTimeError = null);
      return;
    }

    final expirationDateTime = DateTime(
      _expirationDate!.year,
      _expirationDate!.month,
      _expirationDate!.day,
      _expirationTime!.hour,
      _expirationTime!.minute,
    );

    final now = DateTime.now();
    final fiveMinutesFromNow = now.add(const Duration(minutes: 5));

    if (expirationDateTime.isBefore(fiveMinutesFromNow)) {
      setState(() => _expirationDateTimeError = 
        'La date et l\'heure doivent être au moins 5 minutes dans le futur');
    } else {
      setState(() => _expirationDateTimeError = null);
    }
  }

  void _onGeneratePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=<>?';
    final random = Random.secure();
    final password = List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
    
    _passwordController.text = password;
    _confirmPasswordController.text = password;
  }

  Future<void> _selectDate() async {
    // Remove focus from all text fields before opening picker
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!mounted) return;
    final date = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (!mounted) return;
    
    if (date != null) {
      setState(() => _expirationDate = date);
      _validateExpirationDateTime();
    }
    
    // Use post-frame callback to ensure focus is removed after picker closes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
        _dummyFocusNode.requestFocus();
      }
    });
  }

  Future<void> _selectTime() async {
    // Remove focus from all text fields before opening picker
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _expirationTime ?? TimeOfDay.now(),
    );
    
    if (!mounted) return;
    
    if (time != null) {
      setState(() => _expirationTime = time);
      _validateExpirationDateTime();
    }
    
    // Use post-frame callback to ensure focus is removed after picker closes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
        _dummyFocusNode.requestFocus();
      }
    });
  }

  void _showTemporaryInfo() {
    showDialog(
      context: context,
      builder: (context) => const InfoDialog(
        title: 'Mot de passe temporaire',
        message: 'Un mot de passe temporel sera automatiquement supprimé à la date et heure définies.\n\nUtile pour les accès temporaires.',
        icon: Icons.info_outline,
      ),
    );
  }

  /// Affiche un avertissement si le mot de passe est compromis
  Future<void> _showLeakWarningDialog(int leakCount) async {
    final formatted = PasswordBreachService.formatLeakCount(leakCount);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Attention !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(ctx),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le mot de passe a été enregistré, mais il est apparu dans $formatted.',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary(ctx)),
            ),
            const SizedBox(height: 12),
            Text(
              'Il est fortement recommandé de le changer.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(ctx)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('Je comprends'),
          ),
        ],
      ),
    );
  }

  bool get _isFormValid {
    return _titleController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _selectedCategory != null &&
        _passwordController.text.isNotEmpty &&
        _passwordsMatch &&
        (!_isTemporaryPassword || (_expirationDate != null && _expirationTime != null && _expirationDateTimeError == null));
  }

  Future<void> _onSubmit() async {
    setState(() => _showValidationErrors = true);
    _validateExpirationDateTime();
    
    if (!_isFormValid || _isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      // Vérifier si le mot de passe a été compromis
      final leakCount = await PasswordBreachService.checkPasswordLeak(_passwordController.text);
      
      // Créer la date d'expiration complète si temporaire
      DateTime? fullExpirationDate;
      if (_isTemporaryPassword && _expirationDate != null && _expirationTime != null) {
        fullExpirationDate = DateTime(
          _expirationDate!.year,
          _expirationDate!.month,
          _expirationDate!.day,
          _expirationTime!.hour,
          _expirationTime!.minute,
        );
      }
      
      // Créer le modèle avec le résultat de vérification de fuite
      final password = PasswordModel(
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        category: _selectedCategory!.label,
        url: _urlController.text.trim(),
        isTemporary: _isTemporaryPassword,
        expirationDate: fullExpirationDate,
        createdAt: DateTime.now(),
        leakCount: leakCount,
      );
      
      // Enregistrer dans la base de données
      await _databaseService.insertPassword(password);
      
      if (!mounted) return;
      
      // Afficher un avertissement si le mot de passe est compromis
      if (leakCount > 0) {
        await _showLeakWarningDialog(leakCount);
      } else {
        // Afficher un message de succès
        await AppPopup.showSuccess(
          context,
          message: 'Mot de passe enregistré avec succès !',
          onContinue: () {
            Navigator.of(context).pop(true);
          },
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      
      if (!mounted) return;
      
      await AppPopup.showError(
        context,
        message: 'Erreur lors de l\'enregistrement : $e',
        onRetry: () {
          // Fermer le dialog d'erreur
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nouveau mot de passe',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Invisible focus node target
            Focus(
              focusNode: _dummyFocusNode,
              child: const SizedBox.shrink(),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSection(
                    label: 'Titre',
                    child: AppTextField(
                      controller: _titleController,
                      hintText: 'Titre',
                      errorText: _showValidationErrors && _titleController.text.isEmpty
                          ? 'Veuillez saisir un titre'
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  
                  AppSection(
                    label: 'Nom d\'utilisateur',
                    child: AppTextField(
                      controller: _usernameController,
                      hintText: 'Nom d\'utilisateur',
                      errorText: _showValidationErrors && _usernameController.text.isEmpty
                          ? 'Veuillez saisir un nom d\'utilisateur'
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  
                  _buildCategoryField(),
                  const SizedBox(height: AppSizes.spacingMd),
                  
                  _buildPasswordField(),
                  const SizedBox(height: AppSizes.spacingMd),
                  
                  _buildConfirmPasswordField(),
                  const SizedBox(height: AppSizes.spacingMd),
                  
                  AppSection(
                    label: 'URL (optionnel)',
                    child: AppTextField(
                      controller: _urlController,
                      hintText: 'https://example.com',
                      keyboardType: TextInputType.url,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingLg),
                  
                  _buildTemporarySection(),
                  const SizedBox(height: AppSizes.spacingXl),
                  
                  AppButton(
                    text: 'Enregistrer',
                    onPressed: _onSubmit,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    final hasError = _showValidationErrors && _selectedCategory == null;
    
    return AppSection(
      label: 'Catégorie',
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showCategoryDropdown = !_showCategoryDropdown),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              decoration: AppDecorations.bordered(context,
                borderColor: hasError ? AppColors.error : AppColors.border(context),
              ),
              child: Row(
                children: [
                  if (_selectedCategory != null) ...[
                    Icon(_selectedCategory!.icon, size: 20, color: AppColors.primary),
                    const SizedBox(width: AppSizes.spacingSm),
                  ],
                  Expanded(
                    child: Text(
                      _selectedCategory?.label ?? 'Sélectionner une catégorie',
                      style: AppTextStyles.bodyMedium().copyWith(
                        color: _selectedCategory != null
                            ? AppColors.textPrimary(context)
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  Icon(
                    _showCategoryDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ),
            ),
          ),
          if (_showCategoryDropdown)
            Container(
              margin: const EdgeInsets.only(top: AppSizes.spacingSm),
              decoration: AppDecorations.card(context),
              child: Column(
                children: PasswordCategory.values.map((cat) {
                  final isLast = cat == PasswordCategory.values.last;
                  return InkWell(
                    onTap: () => setState(() {
                      _selectedCategory = cat;
                      _showCategoryDropdown = false;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.paddingMd),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: isLast ? BorderSide.none : BorderSide(color: AppColors.border(context)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 20, color: AppColors.primary),
                          const SizedBox(width: AppSizes.spacingMd),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (hasError && !_showCategoryDropdown)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.spacingSm),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                  const SizedBox(width: AppSizes.spacingXs),
                  Text(
                    'Veuillez sélectionner une catégorie',
                    style: AppTextStyles.caption().copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    final hasError = _showValidationErrors && _passwordController.text.isEmpty;
    
    return AppSection(
      label: 'Mot de passe',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _passwordController,
                  hintText: 'Mot de passe',
                  obscureText: _obscurePassword,
                  errorText: hasError ? 'Veuillez saisir un mot de passe' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary(context),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingSm),
              AppIconButton(
                icon: Icons.refresh_rounded,
                onPressed: _onGeneratePassword,
                backgroundColor: AppColors.primary,
                color: AppColors.textOnPrimary,
              ),
            ],
          ),
          if (_passwordStrength != null) ...[
            const SizedBox(height: AppSizes.spacingSm),
            Row(
              children: [
                Icon(Icons.security, size: 14, color: _passwordStrengthColor),
                const SizedBox(width: AppSizes.spacingXs),
                Text(
                  _passwordStrength!,
                  style: AppTextStyles.caption().copyWith(color: _passwordStrengthColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    final hasError = _showValidationErrors && (!_passwordsMatch || _confirmPasswordController.text.isEmpty);
    
    return AppSection(
      label: 'Confirmer le mot de passe',
      child: Column(
        children: [
          AppTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirmer le mot de passe',
            obscureText: _obscureConfirmPassword,
            errorText: hasError
                ? (_confirmPasswordController.text.isEmpty
                    ? 'Veuillez confirmer le mot de passe'
                    : 'Les mots de passe ne correspondent pas')
                : null,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary(context),
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          if (_passwordsMatch && _confirmPasswordController.text.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingSm),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                const SizedBox(width: AppSizes.spacingXs),
                Text(
                  'Les mots de passe correspondent',
                  style: AppTextStyles.caption().copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemporarySection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Mot de passe temporaire',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                onPressed: _showTemporaryInfo,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
              Switch(
                value: _isTemporaryPassword,
                onChanged: (value) => setState(() {
                  _isTemporaryPassword = value;
                  if (!value) {
                    _expirationDate = null;
                    _expirationTime = null;
                    _expirationDateTimeError = null;
                  }
                }),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                inactiveThumbColor: AppColors.grey400,
                inactiveTrackColor: AppColors.isDark(context) ? AppColors.grey700 : AppColors.grey300,
              ),
            ],
          ),
          if (_isTemporaryPassword) ...[
            Divider(color: AppColors.border(context), height: 24),
            const SizedBox(height: AppSizes.spacingMd),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppButton(
                    text: _expirationDate != null
                        ? '${_expirationDate!.day.toString().padLeft(2, '0')}/${_expirationDate!.month.toString().padLeft(2, '0')}/${_expirationDate!.year}'
                        : 'Date',
                    onPressed: _selectDate,
                    isSecondary: true,
                    icon: const Icon(Icons.calendar_today, size: 16),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSm),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: _expirationTime != null
                        ? _expirationTime!.format(context)
                        : 'Heure',
                    onPressed: _selectTime,
                    isSecondary: true,
                    icon: const Icon(Icons.access_time, size: 16),
                  ),
                ),
              ],
            ),
            if (_showValidationErrors && (_expirationDate == null || _expirationTime == null)) ...[
              const SizedBox(height: AppSizes.spacingSm),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                  const SizedBox(width: AppSizes.spacingXs),
                  Flexible(
                    child: Text(
                      'Veuillez définir une date et une heure d\'expiration',
                      style: AppTextStyles.caption().copyWith(color: AppColors.error),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
            if (_expirationDateTimeError != null) ...[
              const SizedBox(height: AppSizes.spacingSm),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                  const SizedBox(width: AppSizes.spacingXs),
                  Flexible(
                    child: Text(
                      _expirationDateTimeError!,
                      style: AppTextStyles.caption().copyWith(color: AppColors.error),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
