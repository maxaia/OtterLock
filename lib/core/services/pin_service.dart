import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Service de gestion du code PIN
class PinService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Vérifie si un PIN a déjà été enregistré
  Future<bool> hasPinRegistered() async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.userPinKey) != null;
  }

  /// Enregistre un nouveau PIN
  Future<void> savePin(String pin) async {
    final prefs = await _preferences;
    await prefs.setString(AppConstants.userPinKey, pin);
    await resetFailedAttempts();
  }

  /// Vérifie si le PIN est correct
  Future<bool> verifyPin(String pin) async {
    final prefs = await _preferences;
    final savedPin = prefs.getString(AppConstants.userPinKey);
    return pin == savedPin;
  }

  /// Récupère le nombre de tentatives échouées
  Future<int> getFailedAttempts() async {
    final prefs = await _preferences;
    return prefs.getInt(AppConstants.failedAttemptsKey) ?? 0;
  }

  /// Incrémente le nombre de tentatives échouées
  Future<int> incrementFailedAttempts() async {
    final prefs = await _preferences;
    final currentAttempts = await getFailedAttempts();
    final newAttempts = currentAttempts + 1;
    await prefs.setInt(AppConstants.failedAttemptsKey, newAttempts);
    
    // Si on atteint le maximum, on verrouille
    if (newAttempts >= AppConstants.maxFailedAttempts) {
      await _setLockout();
    }
    
    return newAttempts;
  }

  /// Réinitialise les tentatives échouées
  Future<void> resetFailedAttempts() async {
    final prefs = await _preferences;
    await prefs.setInt(AppConstants.failedAttemptsKey, 0);
    await prefs.remove(AppConstants.lockoutEndTimeKey);
  }

  /// Définit le verrouillage
  Future<void> _setLockout() async {
    final prefs = await _preferences;
    final lockoutEndTime = DateTime.now()
        .add(const Duration(minutes: AppConstants.lockoutDurationMinutes))
        .millisecondsSinceEpoch;
    await prefs.setInt(AppConstants.lockoutEndTimeKey, lockoutEndTime);
  }

  /// Vérifie si l'application est verrouillée
  Future<bool> isLockedOut() async {
    final prefs = await _preferences;
    final lockoutEndTime = prefs.getInt(AppConstants.lockoutEndTimeKey);
    
    if (lockoutEndTime == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= lockoutEndTime) {
      // Le verrouillage est terminé, on réinitialise
      await resetFailedAttempts();
      return false;
    }
    
    return true;
  }

  /// Récupère le temps restant avant déverrouillage (en secondes)
  Future<int> getRemainingLockoutTime() async {
    final prefs = await _preferences;
    final lockoutEndTime = prefs.getInt(AppConstants.lockoutEndTimeKey);
    
    if (lockoutEndTime == null) return 0;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = ((lockoutEndTime - now) / 1000).ceil();
    
    return remaining > 0 ? remaining : 0;
  }
}
