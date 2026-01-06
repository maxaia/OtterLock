import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_model.dart';
import 'encryption_service.dart';

/// Service de gestion de la base de données SQLite
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  final EncryptionService _encryptionService = EncryptionService();

  /// Champs sensibles à crypter
  static const List<String> _encryptedFields = ['username', 'password', 'url'];

  /// Récupère l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données
  Future<Database> _initDatabase() async {
    // Initialiser le service de cryptographie
    await _encryptionService.initialize();
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'otterlock.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crée les tables de la base de données
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        expirationDate TEXT,
        isTemporary INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Index pour améliorer les performances
    await db.execute('CREATE INDEX idx_category ON passwords(category)');
    await db.execute('CREATE INDEX idx_temporary ON passwords(isTemporary)');
  }

  /// Met à jour la structure de la base de données
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Gérer les migrations futures
  }

  /// Ajoute un nouveau mot de passe
  Future<int> insertPassword(PasswordModel password) async {
    final db = await database;
    
    // Crypter les données sensibles
    final encryptedData = _encryptionService.encryptMap(
      password.toMap(),
      _encryptedFields,
    );
    
    return await db.insert('passwords', encryptedData);
  }

  /// Récupère tous les mots de passe
  Future<List<PasswordModel>> getAllPasswords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passwords',
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) {
      // Décrypter les données sensibles
      final decryptedMap = _encryptionService.decryptMap(map, _encryptedFields);
      return PasswordModel.fromMap(decryptedMap);
    }).toList();
  }

  /// Récupère les mots de passe par catégorie
  Future<List<PasswordModel>> getPasswordsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passwords',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) {
      final decryptedMap = _encryptionService.decryptMap(map, _encryptedFields);
      return PasswordModel.fromMap(decryptedMap);
    }).toList();
  }

  /// Recherche des mots de passe
  Future<List<PasswordModel>> searchPasswords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passwords',
      where: 'title LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) {
      final decryptedMap = _encryptionService.decryptMap(map, _encryptedFields);
      return PasswordModel.fromMap(decryptedMap);
    }).toList();
  }

  /// Met à jour un mot de passe
  Future<int> updatePassword(PasswordModel password) async {
    final db = await database;
    
    final encryptedData = _encryptionService.encryptMap(
      password.toMap(),
      _encryptedFields,
    );
    
    return await db.update(
      'passwords',
      encryptedData,
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  /// Supprime un mot de passe
  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime les mots de passe expirés
  Future<int> deleteExpiredPasswords() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    return await db.delete(
      'passwords',
      where: 'isTemporary = 1 AND expirationDate < ?',
      whereArgs: [now],
    );
  }

  /// Compte le nombre de mots de passe par catégorie
  Future<Map<String, int>> getPasswordCountByCategory() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM passwords
      GROUP BY category
    ''');

    return Map.fromEntries(
      result.map((row) => MapEntry(row['category'] as String, row['count'] as int)),
    );
  }

  /// Ferme la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Réinitialise complètement la base de données
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'otterlock.db');
    
    await deleteDatabase(path);
    _database = null;
    await _encryptionService.reset();
  }
}
