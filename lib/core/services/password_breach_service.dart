import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Service pour vérifier si un mot de passe a été compromis
/// Utilise l'API Have I Been Pwned avec la méthode k-Anonymity
/// pour garantir que le mot de passe n'est jamais envoyé en clair
class PasswordBreachService {
  static const String _apiUrl = 'https://api.pwnedpasswords.com/range/';
  
  /// Vérifie si un mot de passe a été compromis dans des fuites de données
  /// 
  /// Retourne le nombre de fois que le mot de passe a été vu dans des fuites
  /// Retourne 0 si le mot de passe n'a jamais été compromis
  /// Retourne -1 en cas d'erreur (réseau, API, etc.)
  /// 
  /// Exemple d'utilisation:
  /// ```dart
  /// final leakCount = await PasswordBreachService.checkPasswordLeak('mypassword');
  /// if (leakCount > 0) {
  ///   print('Ce mot de passe a été compromis $leakCount fois !');
  /// } else if (leakCount == 0) {
  ///   print('Mot de passe sécurisé !');
  /// } else {
  ///   print('Erreur lors de la vérification');
  /// }
  /// ```
  static Future<int> checkPasswordLeak(String password) async {
    try {
      // 1. Hacher le mot de passe en SHA-1
      final bytes = utf8.encode(password);
      final digest = sha1.convert(bytes);
      final hash = digest.toString().toUpperCase();
      
      // 2. Séparer le préfixe (5 premiers caractères) et le suffixe
      final prefix = hash.substring(0, 5);
      final suffix = hash.substring(5);
      
      // 3. Envoyer uniquement le préfixe à l'API (k-Anonymity)
      final response = await http.get(
        Uri.parse('$_apiUrl$prefix'),
        headers: {
          'User-Agent': 'OtterLock-PasswordManager',
          'Add-Padding': 'true', // Ajoute du padding pour masquer la taille de réponse
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('', 408),
      );
      
      // 4. Vérifier la réponse
      if (response.statusCode != 200) {
        return -1; // Erreur API
      }
      
      // 5. Chercher notre suffixe dans la liste retournée
      // Format de réponse: SUFFIXE:COUNT\r\n
      final lines = response.body.split('\r\n');
      
      for (final line in lines) {
        if (line.isEmpty) continue;
        
        final parts = line.split(':');
        if (parts.length != 2) continue;
        
        final responseSuffix = parts[0];
        final count = int.tryParse(parts[1]) ?? 0;
        
        // Si le suffixe correspond, le mot de passe a été compromis
        if (responseSuffix == suffix) {
          return count;
        }
      }
      
      // Mot de passe non trouvé = jamais compromis
      return 0;
      
    } catch (_) {
      // Erreur réseau ou autre
      return -1;
    }
  }
  
  /// Vérifie un mot de passe et retourne un résultat formaté
  static Future<BreachCheckResult> checkPassword(String password) async {
    final count = await checkPasswordLeak(password);
    return BreachCheckResult(
      isCompromised: count > 0,
      leakCount: count,
      hasError: count == -1,
    );
  }
  
  /// Formate le nombre de fuites pour l'affichage
  static String formatLeakCount(int count) {
    if (count < 0) return 'Vérification impossible';
    if (count == 0) return 'Non compromis';
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M fuites';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K fuites';
    }
    return '$count fuites';
  }
}

/// Résultat de la vérification de fuite
class BreachCheckResult {
  final bool isCompromised;
  final int leakCount;
  final bool hasError;
  
  const BreachCheckResult({
    required this.isCompromised,
    required this.leakCount,
    required this.hasError,
  });
  
  /// Message d'avertissement à afficher
  String get warningMessage {
    if (hasError) {
      return 'Impossible de vérifier ce mot de passe. Vérifiez votre connexion internet.';
    }
    if (isCompromised) {
      final formatted = PasswordBreachService.formatLeakCount(leakCount);
      return 'Ce mot de passe est apparu dans $formatted. Il est fortement recommandé de le changer.';
    }
    return 'Ce mot de passe n\'a pas été trouvé dans les fuites de données connues.';
  }
}
