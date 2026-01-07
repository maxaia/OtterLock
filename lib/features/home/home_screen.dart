import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/password_model.dart';
import '../../core/services/database_service.dart';
import '../../shared/widgets/category_card.dart';
import '../../shared/widgets/password_card.dart';
import '../password/add_password_screen.dart';

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
  
  // Cache RegExp pour optimiser les performances
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
      // Supprimer les mots de passe expirés
      await _databaseService.deleteExpiredPasswords();
      
      // Charger tous les mots de passe
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
    // petite animation avant navigation
    await _fabController.forward();
    await _fabController.reverse();

    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddPasswordScreen()),
    );
    // Recharger les données si un mot de passe a été ajouté
    if (result == true) await _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.overlayLight),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(Icons.search_rounded, color: AppColors.grey400, size: 22),
            ),
            Expanded(
              child: TextField(
                focusNode: _searchFocus,
                controller: _searchController,
                cursorColor: AppColors.primary,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Rechercher un mot de passe...',
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
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppSizes.spacingLg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.h4,
            ),
            if (_searchController.text.isEmpty && _selectedCategory == 'Tous') ...[              
              const SizedBox(height: AppSizes.spacingMd),
              Text(
                'Appuyez sur + pour ajouter\nun nouveau mot de passe',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
          style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
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
              onTap: () {
                // TODO: Naviguer vers l'écran de détails/édition
              },
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer'),
                    content: Text('Voulez-vous supprimer "${password.title}" ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true && password.id != null) {
                  await _databaseService.deletePassword(password.id!);
                  await _loadPasswords();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mot de passe supprimé'),
                        backgroundColor: AppColors.success,
                      ),
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
