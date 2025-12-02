/// Constantes de l'application OtterLock
class AppConstants {
  AppConstants._();

  // PIN
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const int maxFailedAttempts = 5;
  static const int lockoutDurationMinutes = 5;
  
  // Animations
  static const int pinCharDisplayDurationMs = 1000;
  static const int buttonPressDurationMs = 150;
  
  // SharedPreferences keys
  static const String userPinKey = 'user_pin';
  static const String failedAttemptsKey = 'failed_attempts';
  static const String lockoutEndTimeKey = 'lockout_end_time';
}
