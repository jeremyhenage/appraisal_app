# Implementation Plan - Phase 4: Integration

## Goal Description

Connect the "Tactical Dark" Flutter frontend (Phase 3) to the "Forensic" Cloud Functions backend (Phase 2). This involves implementing the data layer (Repositories), state management (Riverpod), and Firebase Authentication to enable real-time firearms appraisal and valuation.

## User Review Required

> [!WARNING]
> This phase requires a live Firebase project. Ensure `firebase_options.dart` is configured and `flutterfire configure` has been run if not already present.

## Proposed Changes

### 1. Data Layer (Repositories)

#### [NEW] [lib/features/appraisal/data/repositories/appraisal_repository.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/features/appraisal/data/repositories/appraisal_repository.dart)

- Implement `AppraisalRepository`.
- **Method**: `Future<AppraisalResult> appraiseItem({required XFile image})`.
- **Logic**:
  1. Upload image to Firebase Storage (bucket: `appraisals/{uid}/{timestamp}.jpg`).
  2. Call Cloud Function `appraise_item` with image URL (gs://...).
  3. Deserialize JSON response into `AppraisalResult` entity.

### 2. State Management (Riverpod)

#### [NEW] [lib/features/appraisal/application/appraisal_providers.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/features/appraisal/application/appraisal_providers.dart)

- `appraisalRepositoryProvider`: Vends the repository instance.
- `appraisalControllerProvider`: `AsyncNotifier` that manages the state of the appraisal process (Loading, Success, Error) and updates the UI.

### 3. Feature Integration

#### [MODIFY] [lib/features/appraisal/presentation/screens/camera_screen.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/features/appraisal/presentation/screens/camera_screen.dart)

- Replace `todo` in `FloatingActionButton` with actual call to `ref.read(appraisalControllerProvider.notifier).analyze(image)`.
- Show loading overlay during analysis.

#### [MODIFY] [lib/features/appraisal/presentation/screens/deal_dashboard_screen.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/features/appraisal/presentation/screens/deal_dashboard_screen.dart)

- Remove `AppraisalResult.mock()`.
- Accept `AppraisalResult` as a constructor argument or read from a provider (depending on navigation strategy).

### 4. Authentication

#### [MODIFY] [lib/main.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/main.dart)

- Initialize `Firebase.initializeApp()`.
- Implement `FirebaseAuth.signInAnonymously()` on app start to ensure backend security rules pass.

## Verification Plan

### Automated Tests

- **Unit Tests**: Mock `AppraisalRepository` and test `AppraisalController` logic.
- **Integration Tests**: Verify Cloud Function calls (using emulators if possible).

### Manual Verification

- **End-to-End Flow**:
  1. Take photo in Camera Screen.
  2. Verify loading state appears.
  3. Verify transition to Deal Dashboard.
  4. **CRITICAL**: Confirm data displayed matches the _real_ analysis of the photo (not mock data).
