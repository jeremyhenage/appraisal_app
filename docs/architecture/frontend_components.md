# AppraisalApp — Frontend Component Map

> Flutter architecture reference as of commit `9f8c4fb`.  
> State management: **Riverpod**. Architecture: **feature-first**.

---

## Directory Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   └── theme/
│       └── app_theme.dart
└── features/
    └── appraisal/
        ├── application/
        │   └── appraisal_providers.dart
        ├── data/
        │   └── repositories/
        │       └── appraisal_repository.dart
        ├── domain/
        │   └── entities/
        │       └── appraisal_result.dart
        └── presentation/
            ├── screens/
            │   ├── camera_screen.dart
            │   └── deal_dashboard_screen.dart
            └── widgets/
                ├── targeting_reticle.dart
                └── liquidity_indicator.dart
```

---

## Dependency Injection Chain (Riverpod)

```
ProviderScope (main.dart)
  │
  ├── appraisalRepositoryProvider (Provider<AppraisalRepository>)
  │       └── creates: AppraisalRepository()
  │                 injects: FirebaseFunctions, FirebaseStorage, FirebaseAuth
  │
  └── appraisalControllerProvider (AsyncNotifierProvider<AppraisalController, AppraisalResult?>)
          └── reads: appraisalRepositoryProvider
          └── exposes state to: CameraScreen (Consumer)
```

---

## Component Inventory

### `main.dart` — App Shell

```dart
void main() async {
  // 1. Firebase init
  // 2. Anonymous auth (+ macOS Persistence.NONE)
  // 3. runApp(ProviderScope(child: AppraisalApp()))
}

class AppraisalApp extends StatelessWidget {
  // MaterialApp with AppTheme.darkTheme
  // Routes: '/' → CameraScreen, '/dashboard' → DealDashboardScreen
}
```

**Routing note:** Uses `onGenerateRoute` (not named routes or `go_router`). The `/dashboard` route
reads `settings.arguments as AppraisalResult?` and falls back to `AppraisalResult.mock()` if null.

---

### `core/theme/app_theme.dart` — Theme

- Exports `AppTheme.darkTheme` (a `ThemeData`)
- Uses `flex_color_scheme` package for consistent material theming
- This is the **only place** global colors, font sizes, and material component defaults should be set
- **Do not** set ad-hoc colors in widget files; reference theme tokens instead

---

### `application/appraisal_providers.dart` — State Hub

| Provider                      | Type                                                           | Purpose                      |
| ----------------------------- | -------------------------------------------------------------- | ---------------------------- |
| `appraisalRepositoryProvider` | `Provider<AppraisalRepository>`                                | Creates repository singleton |
| `appraisalControllerProvider` | `AsyncNotifierProvider<AppraisalController, AppraisalResult?>` | Manages appraisal lifecycle  |

**`AppraisalController` state machine:**

```
Initial:  AsyncValue.data(null)     ← no scan yet
Loading:  AsyncValue.loading()      ← analyze() called
Success:  AsyncValue.data(result)   ← result received
Error:    AsyncValue.error(e, st)   ← something failed
Reset:    AsyncValue.data(null)     ← reset() called
```

**Methods:**

```dart
Future<void> analyze(XFile image) // Triggers full pipeline
void reset()                       // Returns to initial state
```

---

### `data/repositories/appraisal_repository.dart` — Data Layer

**Constructor injection** (supports testing/mocking):

```dart
AppraisalRepository({
  FirebaseFunctions? functions,  // defaults to us-central1 instance
  FirebaseStorage? storage,      // defaults to FirebaseStorage.instance
  FirebaseAuth? auth,            // defaults to FirebaseAuth.instance
})
```

**`appraiseItem(XFile image)` steps:**

1. Resolve UID (currentUser, signInAnonymously, or macOS debug mock)
2. `image.readAsBytes()` → `storageRef.putData(bytes)`
3. Build `gs://bucket/path` URI
4. `_functions.httpsCallable('appraise_item').call({'imageUrl': gsUri})`
5. `AppraisalResult.fromJson(Map<String, dynamic>.from(result.data))`

**Platform special cases:**

- Uses `putData()` always (not `putFile()`) — avoids macOS sandbox file descriptor issues
- Auth mock fallback on `Platform.isMacOS && kDebugMode`

---

### `domain/entities/appraisal_result.dart` — Domain Model

**Pure Dart class** — no Firebase, no Riverpod, no packages.

```dart
class AppraisalResult {
  final String make;
  final String model;
  final double minPrice;       // maps from valuation.wholesale_price
  final double maxPrice;       // maps from valuation.map_price
  final String liquidityScore; // "High" | "Medium" | "Low"
  final String confidence;     // "High" | "Medium" | "Low"
  final List<String> comparables;
}
```

**Factories:**

- `AppraisalResult.mock()` — Glock 19 Gen 5, used for UI development and dashboard fallback
- `AppraisalResult.fromJson(json)` — parses Cloud Function nested response:
  - `json['analysis']` → make, model, is_current_production
  - `json['valuation']` → estimated_value, wholesale_price, map_price, comparables, valuation_confidence

---

### `presentation/screens/camera_screen.dart` — Camera UI

**Type:** `ConsumerStatefulWidget`

**State fields:**

```dart
CameraController? _mobileController       // mobile only
CameraMacOSController? _macOSController   // macOS only
bool _isCameraInitialized
bool _isMockMode                          // true when no camera found
String? _errorMessage
```

**Platform branching:**

```
Platform.isMacOS == true:
  → CameraMacOSView widget (handles its own lifecycle)
  → takePicture() returns CameraMacOSFile with bytes

Platform.isMacOS == false:
  → CameraController initialized manually
  → takePicture() returns XFile path
```

**Build layers (Stack):**

1. Camera preview (or mock view if offline)
2. `TargetingReticle` CustomPainter (IgnorePointer — decorative only)
3. Loading overlay ("ANALYZING BALLISTICS...") — shown during `AsyncValue.loading()`
4. FAB camera button (hidden during loading)
5. Mock mode error label

**Navigation:** `Navigator.of(context).pushNamed('/dashboard')` — called immediately after
`controllerNotifier.analyze(image)` returns (not waiting on the listener callback). The dashboard
reads state from the provider directly.

---

### `presentation/screens/deal_dashboard_screen.dart` — Results UI

Receives `AppraisalResult` via route arguments. Displays appraisal output in the tactical dark theme.

Key UI elements:

- Make / Model header
- Price range bar (min → max)
- `LiquidityIndicator` widget
- Confidence badge
- Comparables list

---

### `presentation/widgets/targeting_reticle.dart` — Reticle Overlay

```dart
class TargetingReticlePainter extends CustomPainter
```

- Draws corner bracket reticle (tactical aesthetic)
- Painted in `Theme.of(context).primaryColor` (adapts to theme changes)
- Rendered as `IgnorePointer` — pure visual, no interaction

---

### `presentation/widgets/liquidity_indicator.dart` — Liquidity Badge

Small stateless widget. Input: `String liquidityScore` ("High" | "Medium" | "Low").

Color mapping:

- "High" → green
- "Medium" → amber
- "Low" → red

---

## Adding a New Feature

1. Create `lib/features/<feature_name>/` with `application/`, `data/`, `domain/`, `presentation/` subdirectories
2. Define domain entity in `domain/entities/`
3. Create repository in `data/repositories/` with injected Firebase dependencies
4. Add Riverpod providers in `application/`
5. Build screens in `presentation/screens/`, widgets in `presentation/widgets/`
6. Register route in `main.dart → onGenerateRoute`
7. Write widget tests in `test/features/<feature_name>/`

---

## Key Dependencies

| Package                         | Version   | Used For                                     |
| ------------------------------- | --------- | -------------------------------------------- |
| `flutter_riverpod`              | ^2.4.9    | State management                             |
| `camera`                        | ^0.10.5+9 | Mobile camera                                |
| `camera_macos`                  | ^0.0.9    | macOS camera                                 |
| `image_picker`                  | ^1.2.1    | Gallery image fallback                       |
| `google_mlkit_text_recognition` | ^0.13.0   | On-device OCR (wired backend, not yet in UI) |
| `firebase_core`                 | ^4.4.0    | Firebase initialization                      |
| `firebase_auth`                 | ^6.1.4    | Anonymous authentication                     |
| `cloud_functions`               | ^6.0.6    | Callable function invocation                 |
| `firebase_storage`              | ^13.0.6   | Image upload                                 |
| `flutter_animate`               | ^4.5.0    | Animations                                   |
| `flex_color_scheme`             | ^8.0.0    | Theme system                                 |
| `google_fonts`                  | ^6.1.0    | Typography                                   |
| `http`                          | ^1.2.0    | Generic HTTP (not currently used actively)   |
