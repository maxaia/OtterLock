import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/password_model.dart';
import '../../core/services/database_service.dart';
import '../../shared/widgets/category_card.dart';
import '../../shared/widgets/password_card.dart';
import '../../shared/widgets/app_popup.dart';
import '../password/add_password_screen.dart';
import '../password/edit_password_screen.dart';
import '../settings/settings_screen.dart';

/// Écran principal affichant les catégories et mots de passe
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  static final RegExp _urlProtocolRegex = RegExp(r'https?://(www\.)?');
  
  String _selectedCategory = 'Tous';
  List<PasswordModel> _allPasswords = [];
  List<PasswordModel> _filteredPasswords = [];
  Map<String, int> _categoryCounts = {};
  bool _isLoading = true;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Tous', 'icon': Icons.apps_rounded},
    {'label': 'E-mail', 'icon': Icons.email_outlined},
    {'label': 'Travail', 'icon': Icons.work_outline},
    {'label': 'Réseaux', 'icon': Icons.share_outlined},
    {'label': 'Banque', 'icon': Icons.account_balance_outlined},
    {'label': 'Autre', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadPasswords();
    _searchController.addListener(_onSearchChanged);
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _fabAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPasswords() async {
    setState(() => _isLoading = true);
    
    try {
      await _databaseService.deleteExpiredPasswords();
      final passwords = await _databaseService.getAllPasswords();
      final counts = await _databaseService.getPasswordCountByCategory();
      
      setState(() {
        _allPasswords = passwords;
        _categoryCounts = counts;
        _filterPasswords();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement : $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    _filterPasswords();
  }

  void _filterPasswords() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredPasswords = _allPasswords.where((password) {
        // Filtrer par catégorie
        final matchesCategory = _selectedCategory == 'Tous' || 
                                password.category == _selectedCategory;
        
        // Filtrer par recherche
        final title = password.title.toLowerCase();
        final username = password.username.toLowerCase();
        final category = password.category.toLowerCase();
        final url = password.url.toLowerCase();
        final urlHost = url.replaceAll(_urlProtocolRegex, '');

        final matchesSearch = query.isEmpty ||
            title.contains(query) ||
            username.contains(query) ||
            category.contains(query) ||
            url.contains(query) ||
            urlHost.contains(query);
        
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterPasswords();
    });
  }

  Future<void> _onAddPassword() async {
    if (!mounted) return;
    await _fabController.forward();
    await _fabController.reverse();

    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddPasswordScreen()),
    );
    if (result == true) await _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      floatingActionButton: RotationTransition(
        turns: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _onAddPassword,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, size: 32, color: AppColors.textOnPrimary),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadPasswords,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: AppSizes.paddingLg,
                          right: AppSizes.paddingLg,
                          bottom: 100,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSizes.spacingMd),
                            _buildCategoriesGrid(),
                            const SizedBox(height: AppSizes.spacingXl),
                            _filteredPasswords.isEmpty 
                                ? _buildEmptyState() 
                                : _buildPasswordsList(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: AppSizes.paddingLg,
        right: AppSizes.paddingLg,
        bottom: AppSizes.paddingMd,
      ),
      color: AppColors.primary,
      child: Row(
        children: [
          // Bouton paramètres
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.searchBackground(context),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.overlayLight),
              ),
              child: Icon(
                Icons.settings,
                color: AppColors.textSecondary(context),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingSm),
          // Barre de recherche
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.searchBackground(context),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.overlayLight),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Icon(Icons.search_rounded, color: AppColors.textSecondary(context), size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocus,
                      controller: _searchController,
                      cursorColor: AppColors.primary,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un mot de passe...',
                        hintStyle: TextStyle(color: AppColors.textSecondary(context)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.spacingMd,
        mainAxisSpacing: AppSizes.spacingMd,
        childAspectRatio: 1.25,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final label = category['label'] as String;
        final count = label == 'Tous'
          ? _allPasswords.length
          : (_categoryCounts[label] ?? 0);
        
        return CategoryCard(
          label: label,
          icon: category['icon'] as IconData,
          isSelected: _selectedCategory == label,
          onTap: () => _onCategorySelected(label),
          count: count,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final message = _searchController.text.isNotEmpty
        ? 'Aucun résultat pour "${_searchController.text}"'
        : _selectedCategory != 'Tous'
            ? 'Aucun mot de passe dans "$_selectedCategory"'
            : 'Aucun mot de passe enregistré';
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.spacingLg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            if (_searchController.text.isEmpty && _selectedCategory == 'Tous') ...[              
              const SizedBox(height: AppSizes.spacingMd),
              Text(
                'Appuyez sur + pour ajouter\nun nouveau mot de passe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_filteredPasswords.length} mot${_filteredPasswords.length > 1 ? 's' : ''} de passe',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredPasswords.length,
          itemBuilder: (context, index) {
            final password = _filteredPasswords[index];
            return PasswordCard(
              key: ValueKey(password.id),
              password: password,
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditPasswordScreen(
                      password: password,
                      initialEditMode: true,
                    ),
                  ),
                );
                if (result == true) await _loadPasswords();
              },
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    title: const Text('Supprimer ce mot de passe ?'),
                    content: Text(
                      'Êtes-vous sûr de vouloir supprimer "${password.title}" ?\n\nCette action est irréversible.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Annuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context))),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        ),
                        child: Text('Supprimer', style: AppTextStyles.button.copyWith(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true && password.id != null) {
                  await _databaseService.deletePassword(password.id!);
                  
                  if (mounted) {
                    await AppPopup.showSuccess(
                      context,
                      message: 'Mot de passe supprimé avec succès !',
                      onContinue: () async {
                        await _loadPasswords();
                      },
                    );
                  }
                }
              },
            );
          },
        ),
      ],
    );
  }
}
