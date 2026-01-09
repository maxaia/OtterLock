import 'package:flutter/material.dart';

/// Catégories de mots de passe partagées entre les écrans
enum PasswordCategory {
  email('E-mail', Icons.email_outlined),
  work('Travail', Icons.work_outline),
  social('Réseaux', Icons.people_outline),
  bank('Banque', Icons.account_balance_outlined),
  other('Autre', Icons.more_horiz);

  final String label;
  final IconData icon;
  const PasswordCategory(this.label, this.icon);

  /// Trouve une catégorie par son label
  static PasswordCategory fromLabel(String label) {
    return PasswordCategory.values.firstWhere(
      (cat) => cat.label == label,
      orElse: () => PasswordCategory.other,
    );
  }
}
