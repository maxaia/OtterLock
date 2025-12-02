import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Catégories de mots de passe disponibles
enum PasswordCategory {
  all,
  email,
  work,
  social,
  permanent,
  other,
}

extension PasswordCategoryExtension on PasswordCategory {
  String get label {
    switch (this) {
      case PasswordCategory.all:
        return 'Tous';
      case PasswordCategory.email:
        return 'E-mail';
      case PasswordCategory.work:
        return 'Travail';
      case PasswordCategory.social:
        return 'Réseaux';
      case PasswordCategory.permanent:
        return 'Permanents';
      case PasswordCategory.other:
        return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case PasswordCategory.all:
        return Icons.apps_rounded;
      case PasswordCategory.email:
        return Icons.email_rounded;
      case PasswordCategory.work:
        return Icons.work_rounded;
      case PasswordCategory.social:
        return Icons.share_rounded;
      case PasswordCategory.permanent:
        return Icons.lock_rounded;
      case PasswordCategory.other:
        return Icons.more_horiz_rounded;
    }
  }
}

/// Écran principal affichant les catégories et mots de passe
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PasswordCategory _selectedCategory = PasswordCategory.all;
  final TextEditingController _searchController = TextEditingController();

  // TODO: Remplacer par les vrais mots de passe stockés
  final List<dynamic> _passwords = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(PasswordCategory category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onAddPassword() {
    // TODO: Navigation vers l'écran d'ajout de mot de passe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ajout de mot de passe à implémenter'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header avec barre de recherche
            _buildHeader(),
            
            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Grille des catégories
                    _buildCategoriesGrid(),
                    
                    const SizedBox(height: 32),
                    
                    // Liste des mots de passe ou état vide
                    _passwords.isEmpty
                        ? _buildEmptyState()
                        : _buildPasswordsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bouton flottant pour ajouter un mot de passe
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un mot de passe...',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey[400],
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = PasswordCategory.values;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory == category;
        
        return _CategoryCard(
          category: category,
          isSelected: isSelected,
          onTap: () => _onCategorySelected(category),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 64,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun mot de passe enregistré',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour ajouter\nun nouveau mot de passe',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        ],
        ),
      ),
    );
  }  Widget _buildPasswordsList() {
    // TODO: Implémenter la liste des mots de passe
    return const SizedBox.shrink();
  }

  Widget _buildAddButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onAddPassword,
          borderRadius: BorderRadius.circular(32),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

/// Carte de catégorie
class _CategoryCard extends StatefulWidget {
  final PasswordCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isSelected
        ? const Color(0xFF0066CC) // Bleu sélectionné
        : AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isPressed
              ? backgroundColor.withOpacity(0.85)
              : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.2),
              blurRadius: _isPressed ? 2 : 4,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.category.icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              widget.category.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
