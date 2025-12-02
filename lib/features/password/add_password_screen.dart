import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Catégories de mots de passe
enum PasswordCategory {
  email('E-mail', Icons.email_outlined),
  work('Travail', Icons.work_outline),
  social('Réseaux', Icons.people_outline),
  bank('Banque', Icons.account_balance_outlined),
  other('Autre', Icons.more_horiz);

  final String label;
  final IconData icon;
  const PasswordCategory(this.label, this.icon);
}

/// Écran d'ajout d'un nouveau mot de passe
class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _urlController = TextEditingController();
  
  PasswordCategory? _selectedCategory;
  bool _isTemporaryPassword = false;
  DateTime? _expirationDate;
  TimeOfDay? _expirationTime;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showCategoryDropdown = false;
  bool _showValidationErrors = false;
  
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
        _passwordStrength = 'Mot de passe faible';
        _passwordStrengthColor = AppColors.error;
      } else if (score <= 4) {
        _passwordStrength = 'Mot de passe moyen';
        _passwordStrengthColor = const Color(0xFFF39C12);
      } else {
        _passwordStrength = 'Mot de passe puissant';
        _passwordStrengthColor = AppColors.success;
      }
    });
    _checkPasswordsMatch();
  }

  void _checkPasswordsMatch() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _passwordsMatch = true);
      return;
    }
    setState(() {
      _passwordsMatch = _passwordController.text == _confirmPasswordController.text;
    });
  }

  String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=';
    final random = Random.secure();
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void _onGeneratePassword() {
    final password = _generatePassword();
    setState(() {
      _passwordController.text = password;
      _confirmPasswordController.text = password;
    });
    _checkPasswordStrength();
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _expirationDate = date);
    }
  }

  Future<void> _selectExpirationTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _expirationTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _expirationTime = time);
    }
  }

  void _showTemporaryPasswordInfo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mot de passe temporel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Un mot de passe temporel sera automatiquement supprimé à la date et à l\'heure que vous aurez définies.\n\nCette fonctionnalité est utile pour les accès temporaires ou les mots de passe à usage limité dans le temps.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Compris',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isFormValid {
    return _titleController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _selectedCategory != null &&
        _passwordController.text.isNotEmpty &&
        _passwordsMatch &&
        (!_isTemporaryPassword || (_expirationDate != null && _expirationTime != null));
  }

  void _onSubmit() {
    setState(() => _showValidationErrors = true);
    
    if (!_isFormValid) return;
    
    final passwordData = {
      'title': _titleController.text,
      'username': _usernameController.text,
      'category': _selectedCategory?.label,
      'password': _passwordController.text,
      'url': _urlController.text,
      'isTemporary': _isTemporaryPassword,
      'expirationDate': _expirationDate,
      'expirationTime': _expirationTime,
    };
    
    _showSuccessDialog(passwordData);
  }

  void _showSuccessDialog(Map<String, dynamic> passwordData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SuccessDialog(
        onContinue: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop(passwordData);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildLabeledField('Titre', _titleController, 'Titre'),
                    const SizedBox(height: 16),
                    _buildLabeledField('Nom d\'utilisateur', _usernameController, 'Nom d\'utilisateur'),
                    const SizedBox(height: 16),
                    _buildCategoryField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 16),
                    _buildLabeledField('URL (optionnel)', _urlController, 'URL', isRequired: false),
                    const SizedBox(height: 24),
                    _buildTemporarySection(),
                    const SizedBox(height: 32),
                    _buildButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: AppColors.primary, size: 24),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Nouveau mot de passe',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.15),
          ),
        ],
      ),
    );
  }

  Widget _buildInputContainer({
    required Widget child,
    bool hasError = false,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasError ? AppColors.error : Colors.black.withOpacity(0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller, String hint, {bool isRequired = true}) {
    final bool hasError = _showValidationErrors && isRequired && controller.text.isEmpty;
    final String? errorMessage = hasError ? 'Veuillez saisir un $hint' : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        _buildInputContainer(
          hasError: hasError,
          child: Center(
            child: TextField(
              controller: controller,
              cursorColor: AppColors.primary,
              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        if (hasError) ...[  
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 12, color: AppColors.error),
              const SizedBox(width: 4),
              Text(errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 10)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryField() {
    final bool hasError = _showValidationErrors && _selectedCategory == null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Catégorie'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _showCategoryDropdown = !_showCategoryDropdown),
          child: _buildInputContainer(
            hasError: hasError,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory?.label ?? 'Catégorie',
                    style: TextStyle(
                      color: _selectedCategory != null ? AppColors.textDark : Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    _showCategoryDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showCategoryDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: PasswordCategory.values.map((cat) {
                final isLast = cat == PasswordCategory.values.last;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = cat;
                    _showCategoryDropdown = false;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 18, color: AppColors.muted),
                        const SizedBox(width: 10),
                        Text(cat.label, style: TextStyle(color: AppColors.muted, fontSize: 14)),
                      ],
                    ),
                  ),
                );  
              }).toList(),
            ),
          ),
        if (_showValidationErrors && _selectedCategory == null && !_showCategoryDropdown) ...[  
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.error_outline, size: 12, color: AppColors.error),
              SizedBox(width: 4),
              Text('Veuillez sélectionner une catégorie', style: TextStyle(color: AppColors.error, fontSize: 10)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    final bool hasError = _showValidationErrors && _passwordController.text.isEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Mot de passe'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildInputContainer(
                hasError: hasError,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          cursorColor: AppColors.primary,
                          style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Mot de passe',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.muted,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _onGeneratePassword,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Center(
                  child: Text(
                    'Générer',
                    style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showValidationErrors && _passwordController.text.isEmpty) ...[
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.error_outline, size: 12, color: AppColors.error),
              SizedBox(width: 4),
              Text('Veuillez saisir votre mot de passe', style: TextStyle(color: AppColors.error, fontSize: 10)),
            ],
          ),
        ] else if (_passwordStrength != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                _passwordStrengthColor == AppColors.success ? Icons.check_circle_outline : Icons.info_outline,
                size: 12,
                color: _passwordStrengthColor,
              ),
              const SizedBox(width: 4),
              Text(_passwordStrength!, style: TextStyle(color: _passwordStrengthColor, fontSize: 10)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Confirmation de votre mot de passe'),
        const SizedBox(height: 6),
        _buildInputContainer(
          hasError: !_passwordsMatch || (_showValidationErrors && _confirmPasswordController.text.isEmpty),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    cursorColor: AppColors.primary,
                    style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showValidationErrors && _confirmPasswordController.text.isEmpty) ...[
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.error_outline, size: 12, color: AppColors.error),
              SizedBox(width: 4),
              Text('Veuillez saisir votre mot de passe', style: TextStyle(color: AppColors.error, fontSize: 10)),
            ],
          ),
        ] else if (!_passwordsMatch) ...[
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.error_outline, size: 12, color: AppColors.error),
              SizedBox(width: 4),
              Text('Les mots de passes ne correspondent pas', style: TextStyle(color: AppColors.error, fontSize: 10)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTemporarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel('Mot de passe temporel'),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showTemporaryPasswordInfo,
              behavior: HitTestBehavior.opaque,
              child: Icon(Icons.info_outline, size: 16, color: AppColors.primary.withOpacity(0.6)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSwitch(),
        if (_isTemporaryPassword) ...[
          const SizedBox(height: 16),
          _buildLabel('Date d\'expiration'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _selectExpirationDate,
                  child: _buildInputContainer(
                    hasError: _showValidationErrors && _expirationDate == null,
                    child: Center(
                      child: Text(
                        _expirationDate != null
                            ? '${_expirationDate!.day.toString().padLeft(2, '0')}/${_expirationDate!.month.toString().padLeft(2, '0')}/${_expirationDate!.year}'
                            : 'JJ/MM/AAAA',
                        style: TextStyle(
                          color: _expirationDate != null ? AppColors.textDark : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _selectExpirationTime,
                  child: _buildInputContainer(
                    hasError: _showValidationErrors && _expirationTime == null,
                    child: Center(
                      child: Text(
                        _expirationTime != null
                            ? '${_expirationTime!.hour.toString().padLeft(2, '0')}:${_expirationTime!.minute.toString().padLeft(2, '0')}'
                            : 'hh:mm',
                        style: TextStyle(
                          color: _expirationTime != null ? AppColors.textDark : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showValidationErrors && (_expirationDate == null || _expirationTime == null)) ...[
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.error_outline, size: 12, color: AppColors.error),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Veuillez saisir la date d\'expiration du mot de passe',
                    style: TextStyle(color: AppColors.error, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSwitch() {
    return GestureDetector(
      onTap: () => setState(() => _isTemporaryPassword = !_isTemporaryPassword),
      child: Container(
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: _isTemporaryPassword ? AppColors.primary : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: _isTemporaryPassword ? 26 : 3,
              top: 4,
              child: Container(
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0xFFE8E9E9)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: Offset(_isTemporaryPassword ? -2 : 2, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: _onSubmit,
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: _isFormValid ? AppColors.primary : const Color(0xFFD6D6D6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isFormValid ? Colors.white : const Color(0xFF8C8C8C),
              ),
            ),
            child: Center(
              child: Text(
                'Valider',
                style: TextStyle(
                  color: _isFormValid ? Colors.white : const Color(0xFF8C8C8C),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary),
            ),
            child: const Center(
              child: Text(
                'Retour',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog de succès avec animation
class _SuccessDialog extends StatefulWidget {
  final VoidCallback onContinue;

  const _SuccessDialog({required this.onContinue});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> with TickerProviderStateMixin {
  late AnimationController _lockController;
  late AnimationController _checkController;
  late AnimationController _scaleController;
  
  late Animation<double> _lockScale;
  late Animation<double> _lockRotation;
  late Animation<double> _checkScale;
  late Animation<double> _backgroundScale;

  @override
  void initState() {
    super.initState();
    
    // Animation du cadenas (rebond + rotation)
    _lockController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _lockScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _lockController, curve: Curves.easeOut));
    
    _lockRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _lockController, curve: Curves.easeOut));
    
    // Animation du check (apparition avec pop)
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _checkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOut));
    
    // Animation du fond
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _backgroundScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    
    // Démarrer les animations en séquence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _lockController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
  }

  @override
  void dispose() {
    _lockController.dispose();
    _checkController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_lockController, _checkController, _scaleController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _backgroundScale.value,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône cadenas avec check animé
                  Transform.scale(
                    scale: _lockScale.value,
                    child: Transform.rotate(
                      angle: _lockRotation.value,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Transform.scale(
                                scale: _checkScale.value,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Message de succès
                  Text(
                    'Nouveau mot de passe\nenregistré avec succès !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bouton Continuer
                  GestureDetector(
                    onTap: widget.onContinue,
                    child: Container(
                      width: 142,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Continuer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}