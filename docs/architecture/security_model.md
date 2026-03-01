# AppraisalApp — Security Model

> Analysis grounded in code as of commit `9f8c4fb` (Feb 28, 2026).

---

## Security Surfaces

### 1. Firebase Authentication

**Mechanism:** Anonymous authentication via `FirebaseAuth.instance.signInAnonymously()`

**Where it happens:**

- `lib/main.dart` — called once on app startup
- `lib/features/appraisal/data/repositories/appraisal_repository.dart` — rechecked before each upload; re-signs in if `currentUser == null`

**What this means:**

- Every user gets a stable, unique UID without providing any credentials
- The UID is the basis for all per-user isolation in Storage
- Anonymous users can be upgraded to named accounts in Phase 4 (email/Google sign-in)
- **No PII is collected or stored in the current implementation**

**macOS special case:**

```dart
// lib/main.dart:20-23
if (defaultTargetPlatform == TargetPlatform.macOS) {
  await FirebaseAuth.instance.setPersistence(Persistence.NONE);
}
```

Persistence is disabled on macOS to avoid `KEYCHAIN_ENTRY_NOT_FOUND` crashes.
This means each macOS session creates a new anonymous UID on restart. A known trade-off.

---

### 2. Firebase Storage Rules

**File:** `storage.rules`

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /appraisals/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**Analysis:**
| Check | Status |
|---|---|
| Auth required before access | ✅ `request.auth != null` |
| User can only access their own files | ✅ `request.auth.uid == userId` |
| Default-deny for all other paths | ✅ explicit `if false` catch-all |
| Publicly readable images | ✅ No — download requires auth token |

**Known gap:** Files uploaded to `appraisals/{uid}/` are never deleted after analysis. This is a cost
and data-retention concern to address in Phase 4 (Cloud Function should delete the GCS object after
Vertex AI has consumed it, or set a lifecycle rule on the bucket).

---

### 3. Firestore Rules

**File:** `firestore.rules`

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Analysis:** Fully locked. No client can read or write Firestore. This is intentional — Firestore
is not used at all in Phase 3. Phase 4 will need rules updated when appraisal history is persisted.

> ⚠️ **Phase 4 reminder:** When adding Firestore writes (e.g. appraisal history), do **not** relax to
> `allow read, write: if request.auth != null`. Write rules should be scoped per collection and
> operation (`allow create: if ...`), not blanket read/write.

---

### 4. Cloud Function Auth Guard

**File:** `functions/main.py:43-48`

```python
if not request.auth:
    logger.warning("Unauthenticated request blocked")
    raise https_fn.HttpsError(
        code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
        message="You must be signed in to use this feature."
    )
```

**Analysis:**

- Firebase Callable Functions automatically pass the auth token from the client SDK
- `request.auth` is `None` if no valid Firebase ID token is present
- The check happens **before** any Gemini API call, preventing unauthenticated usage from incurring cost
- Response is a structured `UNAUTHENTICATED` error, not a raw 401 (correct for Callable Functions)

**What this does NOT protect against:**

- Authenticated users calling the function excessively (no rate limiting)
- The anonymous auth model is trivial to create new UIDs — not true identity verification

---

### 5. Vertex AI / Gemini Access

**Access model:** Application Default Credentials (ADC) via the Cloud Function's service account.

- No Gemini API key is hardcoded anywhere ✅
- The service account used by Cloud Functions (`firearmappraiser@appspot.gserviceaccount.com`) needs
  `roles/aiplatform.user` in GCP IAM
- The GCS bucket for image uploads needs to be accessible to the same service account
- Project ID is hardcoded in `analysis_service.py:29`:
  ```python
  vertexai.init(project="firearmappraiser", location="us-central1")
  ```
  This is acceptable (project IDs are not secrets), but could be moved to an environment variable
  for cleaner multi-environment support

---

### 6. Input Validation

**Backend:**

```python
# functions/main.py:30-34
if not data or 'imageUrl' not in data:
    raise https_fn.HttpsError(
        code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
        message="Missing imageUrl in request data"
    )
```

**Analysis:**

- Presence of `imageUrl` is validated ✅
- The `imageUrl` value itself is not validated (could be any string passed to Vertex AI)
- `ocr_text` is optional and has no length/content validation
- No Pydantic validation is applied to the incoming request in `main.py` (the `AppraisalRequest`
  model in `models.py` exists but is not used in the function handler)

> ⚠️ **Recommendation:** Use `AppraisalRequest` model for input validation in `main.py`. This adds
> type safety and error messages:
>
> ```python
> req = AppraisalRequest(**request.data)
> ```

---

## Security Status Summary

| Surface                                | Status                            | Risk               |
| -------------------------------------- | --------------------------------- | ------------------ |
| Auth required for Cloud Function       | ✅ Enforced                       | Low                |
| Storage — user isolation               | ✅ Enforced                       | Low                |
| Firestore — locked                     | ✅ No access                      | Low                |
| Secrets / API keys hardcoded           | ✅ None found                     | Low                |
| Input validation on imageUrl           | ⚠️ Presence only                  | Medium             |
| Rate limiting on Cloud Function        | ❌ None                           | Medium (cost risk) |
| Pydantic request validation in main.py | ❌ Not used                       | Medium             |
| GCS file cleanup after analysis        | ❌ Not implemented                | Low (cost/privacy) |
| macOS auth persistence                 | ⚠️ Disabled (new UID per session) | Low                |
| Firestore rules for Phase 4 writes     | ⬜ Not yet needed                 | Future             |

---

## Secrets Inventory

No secrets are hardcoded. The following values appear in source but are **not secrets**:

- `firearmappraiser` — GCP Project ID (public identifier)
- Firebase config in `firebase_options.dart` — Firebase public config (API key is a routing key, not a secret; protected by Security Rules)
- `us-central1` — deployment region

Actual secrets (none currently exist, Phase 4 may need):

- RSR Group API credentials → store in **Google Secret Manager**, access via `secretmanager` SDK in Cloud Function
- GunBroker API credentials → same

---

## Threat Model (Brief)

| Threat                                      | Mitigated By               |
| ------------------------------------------- | -------------------------- |
| Unauthenticated Gemini usage                | Cloud Function auth guard  |
| One user accessing another's images         | Storage rules UID check    |
| Client bypassing Cloud Function to write DB | Firestore fully locked     |
| API key theft                               | No API keys used; ADC only |
| Excessive API calls by one user             | ❌ Not yet mitigated       |
| Image data persisting in GCS indefinitely   | ❌ No lifecycle policy     |
