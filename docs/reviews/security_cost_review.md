# Security and Cost Review

**Date:** 2026-02-15
**Status:** MVP / Prototype Phase

## Executive Summary

The application is in a functional prototype state. While the core logic for appraisal and valuation is sound, the current **security posture is critical** due to open access rules, and **cost controls are non-existent**, posing a significant risk of budget overrun if deployed publicly.

## 🚨 Critical Security Vulnerabilities

### 1. Firestore & Storage Rules are Open

- **Location**: `firestore.rules`, `storage.rules`
- **Issue**: Both rulesets are configured to `allow read, write: if true;`.
- **Impact**:
  - **Data Leak**: Any user can dump the entire database and all user uploaded photos.
  - **Data Destruction**: Malicious actors can delete or overwrite all data.
  - **Cost Injection**: Attackers can upload terabytes of data to your storage bucket, incurring massive costs.
- **Recommendation**: Implement owner-based rules immediately.
  ```javascript
  // Example Storage Rule
  match /appraisals/{userId}/{fileName} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
  ```

### 2. Unrestricted Cloud Function Access

- **Location**: `functions/main.py`
- **Issue**: `appraise_item` is a Callable function that authenticates the user but does not **authorize** or **limit** them.
- **Impact**: A single malicious user (even anonymous) can script a loop to call this function millions of times, draining your Gemini quota and billing account.
- **Recommendation**:
  - Implement App Check to ensure calls come from your actual app.
  - Implement server-side rate limiting (e.g., 10 requests/minute per UID).

## 💰 Cost Analysis & Risks

### 1. No Caching Layer

- **Observation**: Every time a user snaps a photo, it is uploaded and sent to Gemini.
- **Risk**: If a user is confused or the UI is slow, they may tap "Appraise" multiple times or retake the same photo.
- **Impact**: Redundant Gemini 1.5/2.0 calls.
- **Recommendation**:
  - Calculate a hash of the image on the client or server.
  - Check Firestore for an existing `AppraisalResult` for that hash before calling Vertex AI.

### 2. Gemini Model Selection

- **Observation**: Currently using `gemini-2.0-flash-exp`.
- **Risk**: "Experimental" models often have lower rate limits and no SLA. When this moves to GA, cost structure may change.
- **Recommendation**: Formalize the model choice to a stable version (e.g., `gemini-1.5-flash`) for production, reserving Pro models only for complex cases if Flash fails (fallback logic).

### 3. Image Storage Optimization

- **Observation**: Full resolution images seem to be uploaded.
- **Risk**: High Storage bandwidth and capacity costs.
- **Recommendation**: Resize images on the client (Flutter) to max 1024x1024 before upload. Gemini does not need 12MP photos for identification.

## 🛠 Code Quality & Best Practices

### Backend (`functions/`)

- **Strengths**:
  - Clean separation of concerns (`services`, `models`).
  - Pydantic models ensure type safety.
- **Weaknesses**:
  - `analysis_service.py` does not validate file types effectively before sending to Vertex.
  - `valuation_service.py` is largely mocked (expected for this phase).

### Frontend (`lib/`)

- **Strengths**:
  - robust `AppraisalRepository` structure.
- **Weaknesses**:
  - `signInAnonymously` is used but anonymous users are never converted or cleaned up.
  - Extensive use of `debugPrint` which can impact performance in release builds (should use a conditional logger).

## Action Plan

1.  **IMMEDIATE**: Lock down `firestore.rules` and `storage.rules`.
2.  **HIGH**: Implement App Check in Flutter and Cloud Functions.
3.  **HIGH**: Add a simple caching layer (Firestore check by image hash) in `appraise_item`.
4.  **MEDIUM**: Add client-side image resizing.
