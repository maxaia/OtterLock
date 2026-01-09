import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/password_model.dart';
import '../../core/services/database_service.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/dialogs.dart';
import '../../shared/widgets/app_popup.dart';
import '../../shared/widgets/password_form_helpers.dart';

/// Écran de modification d'un mot de passe existant
class EditPasswordScreen extends StatefulWidget {
  final PasswordModel password;
  final bool initialEditMode;
  
  const EditPasswordScreen({super.key, required this.password, this.initialEditMode = false});

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
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
  late bool _isEditMode;
  
  String? _passwordStrength;
  Color _passwordStrengthColor = AppColors.muted;
  bool _passwordsMatch = true;
  
  @override
  void initState() {
    super.initState();
    _isEditMode = widget.initialEditMode;
    _initializeFormData();
    _passwordController.addListener(_checkPasswordStrength);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  void _initializeFormData() {
    // Pré-remplir les champs avec les données existantes
    _titleController.text = widget.password.title;
    _usernameController.text = widget.password.username;
    _passwordController.text = widget.password.password;
    _confirmPasswordController.text = widget.password.password;
    _urlController.text = widget.password.url;
    
    _selectedCategory = PasswordCategory.fromLabel(widget.password.category);
    
    // Définir le mode temporaire
    _isTemporaryPassword = widget.password.isTemporary;
    if (_isTemporaryPassword && widget.password.expirationDate != null) {
      _expirationDate = widget.password.expirationDate;
      _expirationTime = TimeOfDay.fromDateTime(widget.password.expirationDate!);
    }
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

  void _onGeneratePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=<>?';
    final random = Random.secure();
    final password = List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
    
    _passwordController.text = password;
    _confirmPasswordController.text = password;
  }

  Future<void> _selectDate() async {
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
        _dummyFocusNode.requestFocus();
      }
    });
  }

  Future<void> _selectTime() async {
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
        _dummyFocusNode.requestFocus();
      }
    });
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
      
      // Mettre à jour le modèle avec les nouvelles données
      final updatedPassword = widget.password.copyWith(
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        category: _selectedCategory!.label,
        url: _urlController.text.trim(),
        isTemporary: _isTemporaryPassword,
        expirationDate: fullExpirationDate,
      );
      
      await _databaseService.updatePassword(updatedPassword);
      
      if (!mounted) return;
      
      await AppPopup.showSuccess(
        context,
        message: 'Mot de passe modifié avec succès !',
        onContinue: () {
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      setState(() => _isSaving = false);
      
      if (!mounted) return;
      
      await AppPopup.showError(
        context,
        message: 'Erreur lors de la modification : $e',
        onRetry: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: const Text('Supprimer ce mot de passe ?'),
        content: const Text('Cette action est irréversible. Le mot de passe sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _databaseService.deletePassword(widget.password.id!);
      
      if (!mounted) return;
      
      await AppPopup.showSuccess(
        context,
        message: 'Mot de passe supprimé avec succès !',
        onContinue: () {
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      await AppPopup.showError(
        context,
        message: 'Erreur lors de la suppression : $e',
        onRetry: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(_isEditMode ? 'Modifier le mot de passe' : 'Détails du mot de passe', style: const TextStyle(fontSize: 18)),
          actions: [
            if (_isEditMode)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditMode = false;
                    _initializeFormData();
                    _showValidationErrors = false;
                  });
                },
                child: const Text('Annuler', style: TextStyle(color: AppColors.textOnPrimary)),
              )
            else
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditMode = true),
                tooltip: 'Éditer',
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _onDelete,
              tooltip: 'Supprimer',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormSection(),
              const SizedBox(height: AppSizes.spacingLg),
              _buildCategorySection(),
              const SizedBox(height: AppSizes.spacingLg),
              _buildTemporarySection(),
              if (_isEditMode) ...[
                const SizedBox(height: AppSizes.spacingXl),
                AppButton(
                  text: _isSaving ? 'Enregistrement...' : 'Enregistrer les modifications',
                  onPressed: _isSaving ? null : _onSubmit,
                  icon: _isSaving ? null : const Icon(Icons.save),
                ),
              ],
              const SizedBox(height: AppSizes.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return AppCard(
      child: Column(
        children: [
          AppTextField(
            controller: _titleController,
            labelText: 'Titre',
            hintText: 'Ex: Mon compte Gmail',
            prefixIcon: const Icon(Icons.title, size: 20),
            enabled: _isEditMode,
            errorText: _showValidationErrors && _titleController.text.isEmpty
                ? 'Ce champ est requis'
                : null,
          ),
          const SizedBox(height: AppSizes.spacingMd),
          AppTextField(
            controller: _usernameController,
            labelText: 'Identifiant',
            hintText: 'E-mail ou nom d\'utilisateur',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            keyboardType: TextInputType.emailAddress,
            enabled: _isEditMode,
            errorText: _showValidationErrors && _usernameController.text.isEmpty
                ? 'Ce champ est requis'
                : null,
          ),
          const SizedBox(height: AppSizes.spacingMd),
          AppTextField(
            controller: _urlController,
            labelText: 'URL (optionnel)',
            hintText: 'https://example.com',
            prefixIcon: const Icon(Icons.link, size: 20),
            keyboardType: TextInputType.url,
            enabled: _isEditMode,
          ),
          const SizedBox(height: AppSizes.spacingMd),
          AppTextField(
            controller: _passwordController,
            labelText: 'Mot de passe',
            hintText: 'Entrez le mot de passe',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            obscureText: _obscurePassword,
            enabled: _isEditMode,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                  onPressed: _onGeneratePassword,
                  tooltip: 'Générer',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
              ],
            ),
            errorText: _showValidationErrors && _passwordController.text.isEmpty
                ? 'Ce champ est requis'
                : null,
          ),
          if (_passwordStrength != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 36),
                Text('Force: ', style: AppTextStyles.caption),
                Text(
                  _passwordStrength!,
                  style: AppTextStyles.caption.copyWith(
                    color: _passwordStrengthColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSizes.spacingMd),
          AppTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirmer',
            hintText: 'Re-saisissez le mot de passe',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            obscureText: _obscureConfirmPassword,
            enabled: _isEditMode,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off, size: 20),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              padding: const EdgeInsets.only(right: 8),
            ),
            errorText: !_passwordsMatch ? 'Les mots de passe ne correspondent pas' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _isEditMode ? () => setState(() => _showCategoryDropdown = !_showCategoryDropdown) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: _showCategoryDropdown ? AppColors.grey50 : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedCategory?.icon ?? Icons.category_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCategory?.label ?? 'Sélectionner une catégorie',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Icon(
                    _showCategoryDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_showCategoryDropdown) ...[
            const AppDivider(),
            ...PasswordCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return InkWell(
                onTap: () => setState(() {
                  _selectedCategory = category;
                  _showCategoryDropdown = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: isSelected ? AppColors.grey50 : Colors.transparent,
                  child: Row(
                    children: [
                      Icon(category.icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        category.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          if (_showValidationErrors && _selectedCategory == null) ...[
            const AppDivider(),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text('Veuillez sélectionner une catégorie', style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemporarySection() {
    return AppCard(
      withShadow: false,
      color: AppColors.grey50,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Mot de passe temporaire',
                  style: AppTextStyles.label,
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
                onChanged: _isEditMode ? (value) => setState(() {
                  _isTemporaryPassword = value;
                  if (!value) {
                    _expirationDate = null;
                    _expirationTime = null;
                    _expirationDateTimeError = null;
                  }
                }) : null,
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.surface;
                  }
                  return AppColors.grey400;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return AppColors.grey200;
                }),
              ),
            ],
          ),
          if (_isTemporaryPassword) ...[
            const AppDivider(),
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
                      style: AppTextStyles.caption.copyWith(color: AppColors.error),
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
                      style: AppTextStyles.caption.copyWith(color: AppColors.error),
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
