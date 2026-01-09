# 🔐 Base de données et Encryption - OtterLock

## Vue d'ensemble

OtterLock utilise **SQLite** + **Encryption AES-256** pour sécuriser les mots de passe.

## 📊 Base de données SQLite

### Table `passwords`

```sql
CREATE TABLE passwords (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  url TEXT NOT NULL,              -- CRYPTÉ
  username TEXT NOT NULL,          -- CRYPTÉ
  password TEXT NOT NULL,          -- CRYPTÉ
  category TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  expirationDate TEXT,
  isTemporary INTEGER DEFAULT 0
)
```

**Emplacement** : `/data/data/.../databases/otterlock.db` (Android)

## 🔒 Encryption

### Principe

- **Master key** (256 bits) stockée dans Keystore/Keychain
- **Salt unique** généré pour chaque donnée
- **Clé dérivée** = SHA-256(masterKey + salt)
- **XOR encryption** avec la clé dérivée

### Initialisation

```dart
// Génération master key (première utilisation)
final bytes = List<int>.generate(32, (_) => random.nextInt(256));
_masterKey = base64Encode(bytes);

// Stockage sécurisé
await _secureStorage.write(key: 'encryption_master_key_v3', value: _masterKey);
```

## 🔐 Cryptage (Encryption)

**Processus en 4 étapes** :

1. **Salt aléatoire** : 8 bytes générés
2. **Dérivation** : `SHA-256(masterKey + salt)` → clé dérivée
3. **XOR** : `texte[i] XOR cléDérivée[i]` → données cryptées
4. **Format** : `SALT:ENCRYPTED_DATA` (Base64)

**Exemple** :
```
"password123" → "aB3dE5fG:Zm9vYmFy=="
                 └─salt  └─données cryptées
```

---

## 🔓 Processus de décryptage

### Étape 1 : Extraction du salt

```dart
final parts = encryptedText.split(':');
final saltBase64 = parts[0];
final encryptedData = base64Decode(parts[1]);
```

### Étape 2 : Recréation de la clé

```dart
final derivedKey = _deriveKey(saltBase64);
```

**Important** : Même salt + même master key = même clé dérivée.

### Étape 3 : Déchiffrement XOR

```dart
final decrypted = <int>[];
for (int i = 0; i < encryptedData.length; i++) {
  decrypted.add(encryptedData[i] ^ derivedKey[i % derivedKey.length]);
}

return utf8.decode(decrypted);
```

**Propriété XOR** : `A XOR B XOR B = A`

---

## 🛡️ Champs cryptés

### Données sensibles
## 🔓 Décryptage (Decryption)

**Processus inverse** :

1. **Split** : Séparer salt et données (`split(':')`)
2. **Dérivation** : Recréer la clé avec le même salt
3. **XOR inverse** : `crypté[i] XOR cléDérivée[i]` → texte clair

## 🛡️ Champs cryptés

**Cryptés** : `username`, `password`, `url`  
**En clair** : `id`, `title`, `category`, `createdAt`, `isTemporary`

**Raison** : Permet les recherches SQL rapides su
---

## 📤 Flux de récupération

### Lecture de mots de passe

```
1. Requête SQLite
   ↓
2. Récupération des Maps avec données cryptées
## 💾 Sauvegarde et Récupération

### Insertion

```dart
// 1. Crypter les champs sensibles
final encryptedData = _encryptionService.encryptMap(
  password.toMap(),
  ['username', 'password', 'url']
);

// 2. Insérer dans SQLite
await db.insert('passwords', encryptedData);
```

### Lecture

```dart
// 1. Récupérer depuis SQLite
final maps = await db.query('passwords');

// 2. Décrypter les champs sensibles
return maps.map((map) {
  final decrypted = _encryptionService.decryptMap(map, _encryptedFields);
  return PasswordModel.fromMap(decrypted);
}).toList();
```

## 🛡️ Sécurité

**✅ Points forts** :
- Master key dans Keystore/Keychain matériel
- Salt unique par donnée
- Dérivation SHA-256

**⚠️ Limitations** :
- XOR moins robuste qu'AES-GCM
- Pas de recherche dans champs cryptés
- Pas d'authentification HMAC

---

**Fichiers** : `encryption_service.dart`, `database_service.dart`