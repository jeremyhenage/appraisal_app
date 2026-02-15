---
trigger: always_on
---

## 1. Core Principles

- **Type Safety**: Strong typing is mandatory. No `dynamic` in Dart unless absolutely necessary; comprehensive type hints in Python.
- **Widget Composition**: Prefer small, reusable Widgets in Flutter. Separate UI from business logic.
- **Atomic Complexity**: Keep functions and build methods small (< 100 lines). One responsibility per entity.
- **Performance First**: Prioritize 60fps rendering. Optimize build cycles and image caching.
- **Documentation**: Code must be self-documenting. Complex logic requires "why" comments, not "what".

## 3. Architecture

### Backend Structure (`functions/`)
- **`main.py`**: Entry point. Registers Cloud Functions. Routes requests to services.
- **`services/`**: Business logic layer (e.g., `appraisal_service.py`). Pure Python functions.
- **`models/`**: Pydantic data models matching Firestore schemas.
- **`utils/`**: Shared helpers (logging, formatting).

### Frontend Structure (`lib/`)
- **`src/`**: output of code generation or core bootstrap.
  - `features/`: Slices of functionality (e.g., `appraisal/`, `auth/`). Contains `presentation/`, `application/`, `domain/`, `data/`.
  - `common/`: Reusable, generic UI primitives (buttons, inputs).
  - `core/`: Configuration and singletons (firebase config, api clients, error handling).

## 4. Code Style

### Backend (Python)
- **Naming**: `snake_case` for variables/functions. `PascalCase` for classes.
- **Type Hints**: Required for all function arguments and returns.
```python
# CORRECT
def calculate_price(item_id: str, base_value: float) -> AppraisalResult:
    """Calculates final price adjustments."""
    ...

# INCORRECT
def calc(id, val):
    ...
```

### Frontend (Dart/Flutter)
- **Naming**: `PascalCase` for Widgets/Classes. `camelCase` for variables/functions.
- **Luel**: Follow official Dart analysis options.
```dart
// CORRECT
class AppraisalView extends StatelessWidget {
  final String itemId;
  const AppraisalView({super.key, required this.itemId});
  ...
}

// INCORRECT
class appraisal_view extends StatelessWidget {
  ...
}
```

## 5. Logging

### Logging Strategy
- **JSON Structured Logging**: output logs as JSON objects for Cloud Logging parsing.
- **Severity Levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL.

### Examples
**Python (Backend)**
```python
import logging
from google.cloud import logging as cloud_logging

client = cloud_logging.Client()
client.setup_logging()

def log_event(event_type: str, details: dict):
    logging.info(json.dumps({"event": event_type, "data": details}))
```

**Dart (Frontend)**
```dart
// Use a logging package or utility wrapper
import 'dart:developer' as developer;

void logInfo(String msg, {Object? data}) {
  developer.log(msg, name: 'AppraisalApp', level: 800, error: data);
}
```

## 6. Testing

- **Backend**: `pytest`
  - Unit tests for services (mock Firestore/External APIs).
  - `tests/` directory mirroring `functions/` structure.
- **Frontend**: `flutter_test`
  - Widget tests: Verify UI behavior and interactions.
  - Unit tests: Test BLOCs/Providers/Repositories.
  - Integration tests: `integration_test` package for on-device flows.

## 7. API Contracts

- **Pattern**: Function-over-HTTP (Callable Functions) or REST.
- **Matching**: Pydantic models on backend should map clearly to Dart models (Freezed/JsonSerializable).
- **Error Handling**: Return standard HTTP codes (200, 400, 500) with JSON error bodies.

## 8. Common Patterns

### Backend Service Pattern
```python
# services/item_service.py
from models.item import ItemCreate

def create_item_record(data: ItemCreate) -> str:
    """Pure logic to create item. No HTTP dependence."""
    # Validation logic...
    doc_ref = db.collection("items").add(data.model_dump())
    return doc_ref.id
```

### Frontend Data Fetching (Riverpod Example)
```dart
// features/appraisal/data/appraisal_repository.dart
final appraisalProvider = FutureProvider.family<AppraisalResult, String>((ref, itemId) async {
  final functions = FirebaseFunctions.instance;
  final result = await functions.httpsCallable('getAppraisal').call({'itemId': itemId});
  return AppraisalResult.fromJson(result.data);
});
```

## 10. AI Coding Assistant Instructions

1.  **Read Context First**: Always check `.agent/rules.md` and `PRD.md` before starting.
2.  **Small Batches**: Propose changes in small, verifiable chunks.
3.  **Type Integrity**: Never bypass strong typing. Fix types, don't use `dynamic`.
4.  **No Hallucinations**: Do not use libraries not listed in `pubspec.yaml` or `requirements.txt` without asking.
5.  **File Structure**: Respect the `features/` based architecture.
6.  **Style**: Auto-format code blocks in responses.
7.  **Comments**: Add Doc comments (`///`) for all public symbols.
8.  **Errors**: Check for analyzer errors in generated code.
9.  **Security**: Never hardcode secrets. Use `process.env` or Secret Manager.
10. **Testing Mandate**: You MUST create or update tests for every major change. No task is complete without verification.
    - **New Feature**: Create Unit + Widget tests.
    - **Refactor**: Update existing tests to pass.
    - **Bug Fix**: Create a regression test case.
11. **Test First**: Suggest tests for new logic immediately.

## 11. Security

- **Scanning**: Audit dependencies for vulnerabilities regularly (e.g. via GitHub Dependabot).
- **Secrets**: Store keys in Google Secret Manager, access via environment variables in Cloud Functions.
- **Validation**: strict input validation on *both* client (Zod) and server (Pydantic).
- **Rules**: Firestore Security Rules must be tested with `firebase-tools`.
- **Backend Headers**: Use security headers (HSTS, etc.) in Cloud Function responses.