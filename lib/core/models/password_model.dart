/// Modèle de données pour un mot de passe
class PasswordModel {
  final int? id;
  final String title;
  final String url;
  final String username;
  final String password;
  final String category;
  final DateTime createdAt;
  final DateTime? expirationDate;
  final bool isTemporary;

  const PasswordModel({
    this.id,
    required this.title,
    required this.url,
    required this.username,
    required this.password,
    required this.category,
    required this.createdAt,
    this.expirationDate,
    this.isTemporary = false,
  });

  /// Convertit le modèle en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'username': username,
      'password': password,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'isTemporary': isTemporary ? 1 : 0,
    };
  }

  /// Crée un modèle depuis une Map de la base de données
  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      url: map['url'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expirationDate: map['expirationDate'] != null
          ? DateTime.parse(map['expirationDate'] as String)
          : null,
      isTemporary: (map['isTemporary'] as int) == 1,
    );
  }

  /// Crée une copie du modèle avec des champs modifiés
  PasswordModel copyWith({
    int? id,
    String? title,
    String? url,
    String? username,
    String? password,
    String? category,
    DateTime? createdAt,
    DateTime? expirationDate,
    bool? isTemporary,
  }) {
    return PasswordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      expirationDate: expirationDate ?? this.expirationDate,
      isTemporary: isTemporary ?? this.isTemporary,
    );
  }

  /// Vérifie si le mot de passe est expiré
  bool get isExpired {
    if (!isTemporary || expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  @override
  String toString() {
    return 'PasswordModel(id: $id, title: $title, category: $category, isTemporary: $isTemporary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
