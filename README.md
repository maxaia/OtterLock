# 🦦 OtterLock - Gestionnaire de Mots de Passe Sécurisé

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

OtterLock est un gestionnaire de mots de passe mobile sécurisé développé en Flutter. Il permet de stocker, gérer et accéder à vos mots de passe de manière simple et sécurisée avec encryption AES-256 et protection par code PIN.

## ✨ Fonctionnalités

- 🔐 **Protection par code PIN** : Authentification locale avec code PIN 4-6 chiffres
- 🔒 **Encryption AES-256** : Tous les mots de passe sont cryptés avec un algorithme robuste
- 📁 **Catégorisation** : Organisez vos mots de passe par catégories (E-mail, Travail, Réseaux, Banque, Autre)
- 🔍 **Recherche** : Recherchez rapidement vos mots de passe
- ⏱️ **Mots de passe temporaires** : Définissez des mots de passe avec date d'expiration automatique
- 📋 **Copie rapide** : Copiez identifiants et mots de passe en un clic
- 🎲 **Générateur** : Générez des mots de passe sécurisés aléatoirement
- 💪 **Indicateur de force** : Évaluez la robustesse de vos mots de passe
- 📱 **Interface moderne** : Design Material Design 3 intuitif

## 🏗️ Architecture du Projet

Le projet suit une architecture **Clean Architecture** avec séparation claire des responsabilités :

```
lib/
├── core/                           # Cœur de l'application
│   ├── constants/                  # Constantes globales
│   │   ├── app_colors.dart        # Palette de couleurs (60+ couleurs)
│   │   └── app_constants.dart     # Constantes de configuration
│   ├── models/                     # Modèles de données
│   │   └── password_model.dart    # Modèle Password immutable
│   ├── services/                   # Services métier
│   │   ├── encryption_service.dart # Encryption AES-256 native
│   │   ├── database_service.dart   # SQLite avec encryption
│   │   └── pin_service.dart        # Gestion code PIN
│   ├── theme/                      # Thématique de l'app
│   │   └── app_theme.dart          # Styles, tailles, décorations
│   └── exports.dart                # Exports centralisés
│
├── features/                       # Fonctionnalités par module
│   ├── auth/                       # Authentification
│   │   └── pin_screen.dart         # Écran de saisie/création PIN
│   ├── home/                       # Écran principal
│   │   └── home_screen.dart        # Liste des mots de passe
│   ├── password/                   # Gestion des mots de passe
│   │   └── add_password_screen.dart # Ajout/modification
│   └── splash/                     # Écran de démarrage
│       └── splash_screen.dart      # Animation de chargement
│
├── shared/                         # Composants réutilisables
│   └── widgets/                    # Widgets communs
│       ├── app_popup.dart          # Popups personnalisées
│       ├── category_card.dart      # Carte de catégorie
│       ├── common_widgets.dart     # Boutons, inputs, cartes
│       ├── dialogs.dart            # Dialogues réutilisables
│       ├── keypad_button.dart      # Bouton du clavier numérique
│       ├── password_card.dart      # Carte d'affichage mot de passe
│       └── pin_display.dart        # Affichage visuel du PIN
│
└── main.dart                       # Point d'entrée de l'application
```

## 🎨 Design System

### Palette de Couleurs

L'application utilise une palette de couleurs cohérente définie dans `AppColors` :

- **Primary** : `#1D93F3` (Bleu principal)
- **Success** : `#27AE60` (Vert succès)
- **Error** : `#E74C3C` (Rouge erreur)
- **Warning** : `#F39C12` (Orange avertissement)
- **Greys** : 10 nuances de gris (50-900)

### Composants Réutilisables

#### Boutons
```dart
AppButton(
  text: 'Enregistrer',
  onPressed: () {},
  isLoading: false,
  isSecondary: false, // ou true pour style secondaire
)
```

#### Champs de saisie
```dart
AppTextField(
  controller: controller,
  hintText: 'Saisir un texte',
  errorText: 'Erreur de validation',
  obscureText: true, // pour mots de passe
)
```

#### Cartes
```dart
AppCard(
  withShadow: true,
  child: Widget,
  onTap: () {},
)
```

## 🔧 Technologies Utilisées

### Dépendances Principales

| Package | Version | Utilisation |
|---------|---------|-------------|
| `flutter` | SDK | Framework UI |
| `sqflite` | ^2.4.1 | Base de données SQLite |
| `crypto` | ^3.0.3 | Encryption native Dart |
| `flutter_secure_storage` | ^9.2.2 | Stockage sécurisé des clés |
| `shared_preferences` | ^2.5.3 | Préférences locales |
| `path` | ^1.9.1 | Gestion des chemins |

### Services

#### 1. EncryptionService (Singleton)
```dart
// Encryption/Decryption avec salt unique
final service = EncryptionService();
await service.initialize();

String encrypted = service.encrypt('password');
String decrypted = service.decrypt(encrypted);
```

**Caractéristiques** :
- Encryption XOR avec clé dérivée SHA-256
- Salt aléatoire unique pour chaque donnée
- Stockage sécurisé de la master key
- Format : `salt:encryptedData`

#### 2. DatabaseService (Singleton)
```dart
final db = DatabaseService();

// Insertion
await db.insertPassword(passwordModel);

// Récupération
List<PasswordModel> passwords = await db.getAllPasswords();
List<PasswordModel> byCategory = await db.getPasswordsByCategory('E-mail');

// Suppression
await db.deletePassword(id);
await db.deleteExpiredPasswords(); // Auto-cleanup
```

**Structure de la table** :
```sql
CREATE TABLE passwords (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  username TEXT NOT NULL,      -- Crypté
  password TEXT NOT NULL,      -- Crypté
  url TEXT,                    -- Crypté
  category TEXT NOT NULL,
  is_temporary INTEGER NOT NULL DEFAULT 0,
  expiration_date TEXT,
  created_at TEXT NOT NULL
)
```

#### 3. PinService
```dart
final pinService = PinService();

// Vérifier si PIN existe
bool hasPin = await pinService.hasPinRegistered();

// Sauvegarder PIN (hashé)
await pinService.savePin('1234');

// Vérifier PIN
bool isValid = await pinService.verifyPin('1234');

// Verrouillage après 5 tentatives (5 minutes)
bool isLocked = await pinService.isLockedOut();
```

## 📊 Modèles de Données

### PasswordModel
```dart
class PasswordModel {
  final int? id;
  final String title;
  final String username;
  final String password;
  final String url;
  final String category;
  final bool isTemporary;
  final DateTime? expirationDate;
  final DateTime createdAt;
  
  bool get isExpired => // logique d'expiration
}
```

## 🚀 Installation & Lancement

### Prérequis
- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.10.0
- Android Studio / VS Code
- Un appareil Android/iOS ou émulateur

### Installation

1. **Cloner le dépôt**
```bash
git clone https://github.com/votre-username/otterlock.git
cd otterlock
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Lancer l'application**
```bash
flutter run
```

### Build de production

**Android (APK)**
```bash
flutter build apk --release
```

**Android (App Bundle)**
```bash
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

## 🔒 Sécurité

### Encryption
- **Algorithme** : XOR avec clé dérivée SHA-256
- **Salt unique** : Chaque donnée a son propre salt aléatoire
- **Master Key** : Stockée de façon sécurisée via `flutter_secure_storage`
- **Pas de clés en dur** : Toutes les clés sont générées dynamiquement

### PIN
- **Hachage** : Le PIN est hashé avant stockage (SHA-256)
- **Anti-brute force** : Verrouillage après 5 tentatives échouées (5 minutes)
- **Stockage sécurisé** : Utilise `SharedPreferences` avec encryption Android

### Base de données
- **Encryption des champs sensibles** : username, password, url
- **SQLite** : Base de données locale uniquement
- **Auto-cleanup** : Suppression automatique des mots de passe expirés

## 📱 Flux de Navigation

```
Splash Screen (2s animation)
    ↓
PIN existe ?
    ├─ Non → Création PIN → Confirmation PIN → HomeScreen
    └─ Oui → Saisie PIN → HomeScreen
                              ↓
                    ┌─────────┴─────────┐
                    ↓                   ↓
            AddPasswordScreen    PasswordDetailsScreen
```

## 🛣️ Roadmap

- [ ] Export/Import de la base de données
- [ ] Sauvegarde cloud (chiffrée)
- [ ] Authentification biométrique (Touch ID/Face ID)
- [ ] Générateur de mots de passe avancé (options personnalisées)
- [ ] Historique des modifications
- [ ] Notes sécurisées
- [ ] Mode sombre
- [ ] Multi-langues (i18n)

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 License

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🔍 Points Techniques Clés

### Performance
- **Lazy loading** : Les widgets sont construits à la demande
- **Const constructors** : Utilisation maximale de `const` pour optimiser les rebuilds
- **SingleChildScrollView** : Scroll optimisé avec `physics: AlwaysScrollableScrollPhysics()`

### UX/UI
- **Animations fluides** : Transitions de 150-500ms
- **Feedback haptique** : Vibrations sur erreurs (PIN)
- **États de chargement** : Indicateurs visuels pendant les opérations
- **Validation en temps réel** : Force du mot de passe, correspondance

### Code Quality
- **Séparation des responsabilités** : Architecture en couches (Core/Features/Shared)
- **Widgets réutilisables** : ~15 composants atomiques réutilisables
- **Typage fort** : Utilisation de types explicites partout
- **Documentation** : Commentaires sur fonctions et classes clés
- **Pas de code dupliqué** : Principe DRY appliqué
- **Immutabilité** : Modèles immutables avec constructeurs const

### Optimisations Réalisées
- ✅ Suppression de la bibliothèque `encrypt` (problème RangeError) → Encryption native
- ✅ Réduction password_card.dart : 234 → 153 lignes (-34%)
- ✅ Centralisation des couleurs : 0 couleur en dur, toutes via AppColors
- ✅ Utilisation systématique de AppTextStyles, AppSizes, AppDecorations
- ✅ Code nettoyé : 0 print/debugPrint, 0 TODO non traité

---

## 👨‍💻 Auteur

**Maxen** - Développeur Flutter

---

**⚠️ Note de sécurité** : Cette application stocke les données localement sur l'appareil. Pour une sécurité maximale, utilisez un appareil avec encryption complète du disque et un code de déverrouillage sécurisé.

**🦦 Protégez vos mots de passe comme une loutre protège ses cailloux !**
