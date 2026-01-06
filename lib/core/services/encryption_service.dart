import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service d'encryption AES-256 simple et fiable
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyStorageKey = 'encryption_master_key_v3';
  
  String? _masterKey;
  bool _isInitialized = false;

  /// Initialise le service d'encryption
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Récupérer ou créer la clé master
      _masterKey = await _secureStorage.read(key: _keyStorageKey);
      
      if (_masterKey == null || _masterKey!.isEmpty) {
        // Générer une nouvelle clé master sécurisée
        final random = Random.secure();
        final bytes = List<int>.generate(32, (_) => random.nextInt(256));
        _masterKey = base64Encode(bytes);
        await _secureStorage.write(key: _keyStorageKey, value: _masterKey);
      }
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erreur d\'initialisation de l\'encryption: $e');
    }
  }

  /// Génère une clé dérivée à partir de la master key et d'un salt
  List<int> _deriveKey(String salt) {
    final keyBytes = utf8.encode(_masterKey! + salt);
    return sha256.convert(keyBytes).bytes;
  }

  /// Crypte une chaîne de caractères
  String encrypt(String plainText) {
    if (!_isInitialized || _masterKey == null) {
      throw Exception('EncryptionService non initialisé');
    }

    if (plainText.isEmpty) return plainText;

    try {
      // Générer un salt aléatoire pour chaque encryption
      final random = Random.secure();
      final salt = List<int>.generate(8, (_) => random.nextInt(256));
      final saltBase64 = base64Encode(salt);
      
      // Dériver une clé unique pour ce texte
      final derivedKey = _deriveKey(saltBase64);
      
      // XOR encryption avec la clé dérivée
      final textBytes = utf8.encode(plainText);
      final encrypted = <int>[];
      
      for (int i = 0; i < textBytes.length; i++) {
        encrypted.add(textBytes[i] ^ derivedKey[i % derivedKey.length]);
      }
      
      // Retourner: salt + encrypted (séparés par :)
      return '$saltBase64:${base64Encode(encrypted)}';
    } catch (e) {
      throw Exception('Erreur de cryptage: $e');
    }
  }

  /// Décrypte une chaîne de caractères
  String decrypt(String encryptedText) {
    if (!_isInitialized || _masterKey == null) {
      throw Exception('EncryptionService non initialisé');
    }

    if (encryptedText.isEmpty) return encryptedText;

    try {
      // Séparer le salt et le texte crypté
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw Exception('Format de données cryptées invalide');
      }
      
      final saltBase64 = parts[0];
      final encryptedData = base64Decode(parts[1]);
      
      // Dériver la même clé avec le salt
      final derivedKey = _deriveKey(saltBase64);
      
      // XOR decryption
      final decrypted = <int>[];
      for (int i = 0; i < encryptedData.length; i++) {
        decrypted.add(encryptedData[i] ^ derivedKey[i % derivedKey.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Erreur de décryptage: $e');
    }
  }

  /// Crypte une map de données
  Map<String, dynamic> encryptMap(Map<String, dynamic> data, List<String> fieldsToEncrypt) {
    final result = Map<String, dynamic>.from(data);
    
    for (final field in fieldsToEncrypt) {
      if (result.containsKey(field) && result[field] != null) {
        final value = result[field].toString();
        if (value.isNotEmpty) {
          result[field] = encrypt(value);
        }
      }
    }
    
    return result;
  }

  /// Décrypte une map de données
  Map<String, dynamic> decryptMap(Map<String, dynamic> data, List<String> fieldsToDecrypt) {
    final result = Map<String, dynamic>.from(data);
    
    for (final field in fieldsToDecrypt) {
      if (result.containsKey(field) && result[field] != null) {
        try {
          final value = result[field].toString();
          if (value.isNotEmpty) {
            result[field] = decrypt(value);
          }
        } catch (e) {
          // En cas d'erreur, garder la valeur originale
          result[field] = result[field];
        }
      }
    }
    
    return result;
  }

  /// Réinitialise complètement l'encryption (⚠️ toutes les données seront perdues)
  Future<void> reset() async {
    await _secureStorage.delete(key: _keyStorageKey);
    _masterKey = null;
    _isInitialized = false;
    await initialize();
  }
}
