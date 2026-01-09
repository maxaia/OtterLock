# 🎬 Animations - OtterLock

## 1. 🌟 Splash Screen

**3 animations synchronisées** :

### Logo (Scale + Fade)
- **Durée** : 1500ms
- **Effet** : Apparition progressive (0→1) + zoom (0.5→1)
- **Curve** : `easeOut`

### Texte "OtterLock" (Slide + Fade)
- **Durée** : 1000ms (démarre à 500ms)
- **Effet** : Glisse de bas en haut + fade in

### Shimmer Loading
- **Durée** : Infinie (boucle 1500ms)
- **Effet** : Gradient animé de gauche à droite

---

## 2. 🔒 PIN Screen - Shake Error

**Animation** : Secousse horizontale sur erreur

```dart
_shakeAnimation = Tween<double>(begin: 0, end: 10)
  .chain(CurveTween(curve: Curves.elasticIn))
  .animate(_shakeController);
```

- **Durée** : 500ms
- **Effet** : ±10px oscillation
- **Trigger** : Code PIN incorrect

---

## 3. 🏠 Home Screen - FAB Rotation

**Animation** : Rotation 45° de l'icône +

```dart
RotationTransition(
  turns: Tween<double>(begin: 0.0, end: 0.125)
    .animate(_rotationController),
  child: Icon(Icons.add),
)
```

- **Durée** : 300ms
- **Angle** : 0.125 tour = 45°
- **Curve** : `easeInOut`

---

## 4. ✅ App Popup - Bounce Success

**Animation** : Pop-up avec rebond

```dart
TweenSequence<double>([
  TweenSequenceItem(tween: Tween(0.0, 1.3), weight: 40),
  TweenSequenceItem(tween: Tween(1.3, 0.95), weight: 30),
  TweenSequenceItem(tween: Tween(0.95, 1.0), weight: 30),
])
```

- **Durée** : 800ms
- **Phases** : 0 → 1.3 (overshoot) → 0.95 → 1.0
- **Curve** : `easeOutBack`

---

## 5. 🗂️ Category Cards

**Animation** : Transition sélection/désélection

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  decoration: BoxDecoration(
    color: isSelected ? AppColors.primary : Colors.white,
    boxShadow: isSelected ? [BoxShadow(...)] : [],
  ),
)
```

- **Propriétés animées** : Couleur, ombre, bordure
- **Durée** : 200ms

---

## 6. 🎹 Keypad Button - Press Scale

**Animation** : Compression au tap

```dart
AnimatedScale(
  scale: _isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 100),
)
```

- **Scale** : 1.0 → 0.95
- **Durée** : 100ms (ultra rapide)

---

## 7. 🟦 PIN Display

**Animation** : Apparition des points

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  width: isFilled ? 16 : 12,
  height: isFilled ? 16 : 12,
  color: isFilled ? AppColors.primary : Colors.grey,
)
```

- **Transition** : Vide → Rempli
- **Durée** : 200ms

---

## 8. 🔘 App Button - Press Scale

**Widget** : `AppButton` (common_widgets.dart)

```dart
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  child: AnimatedScale(
    scale: _isPressed ? 0.95 : 1.0,
    duration: Duration(milliseconds: 100),
  ),
)
```

- **Effet** : Bouton se compresse légèrement
- **Usage** : Boutons "Enregistrer", "Continuer", etc.

---

## 9. 📝 App TextField - Focus Border

**Widget** : `AppTextField` (common_widgets.dart)

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  decoration: BoxDecoration(
    border: Border.all(
      color: _isFocused ? AppColors.primary : Colors.grey,
      width: _isFocused ? 2.0 : 1.0,
    ),
  ),
)
```

- **Effet** : Bordure bleue épaisse au focus
- **Trigger** : `FocusNode` listener

---

## 10. 🎭 Dialogs - Fade + Scale

**Animation** : Apparition modale

```dart
ScaleTransition(
  scale: CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  ),
  child: FadeTransition(
    opacity: controller,
    child: AlertDialog(...),
  ),
)
```

- **Durée** : 300ms
- **Effet** : Zoom + Fade simultané

---

## 📊 Résumé

| Animation | Durée | Curve | Fichier |
|-----------|-------|-------|---------|
| Splash Logo | 1500ms | easeOut | splash_screen.dart |
| PIN Shake | 500ms | elasticIn | pin_screen.dart |
| FAB Rotation | 300ms | easeInOut | home_screen.dart |
| Popup Bounce | 800ms | easeOutBack | app_popup.dart |
| Category Card | 200ms | linear | category_card.dart |
| Button Press | 100ms | linear | common_widgets.dart |
| TextField Focus | 200ms | linear | common_widgets.dart |
| Dialog | 300ms | easeOutCubic | dialogs |
