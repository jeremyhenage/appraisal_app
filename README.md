# AppraisalApp ("Operator")

**Firearm Valuation & Acquisition System**

"Operator" is a high-fidelity mobile application designed for domain experts (FFLs) to provide rapid, "Check and Balance" firearm identification and valuation in the field. It prioritizes precision and depth of analysis to support acquisition decisions.

## key Features

### 1. The "Deep Scan"
Real-time camera feed with on-device OCR (Google ML Kit) to detect and highlight firearm markings (Make, Model, S/N) via a "Targeting Reticle" interface.

### 2. "Forensic Analyst" Intelligence
Leverages **Vertex AI (Gemini 3 Pro)** to analyze images and detected text for rigorously verifying identity, grading condition (NRA Standards), and identifying modifications.

### 3. Bifurcated Valuation Engine
A dual-path valuation logic based on production status:
- **Current Production**: Real-time wholesale pricing (RSR Group API) and MAP benchmarks.
- **Out of Production**: Market analysis via GunBroker "Sold" listing scrapes, cleaned and parsed by Gemini.

### 4. "Tactical Dark" UI
A high-contrast, industrial sci-fi design system optimized for readability and field use, featuring "glitch" animations and data-dense displays.

## Technology Stack

- **Frontend**: Flutter (Dart)
  - State Management: Riverpod / Bloc
  - UI: `flex_color_scheme`, `flutter_animate`, `google_fonts`
  - ML: `google_ml_kit_text_recognition`
- **Backend**: Google Firebase
  - **Auth**: Firebase Auth (Anonymous + Email/Link)
  - **Database**: Cloud Firestore (NoSQL)
  - **Compute**: Cloud Functions (2nd Gen, Python 3.11+)
  - **Storage**: Firebase Storage
- **AI / ML**: Vertex AI (Gemini 3 Pro)
- **Testing**:
  - **Backend**: `pytest` + `vcrpy`
  - **Strategy**: "Golden Set" evaluation against known ground-truth data.

## Goal
Build a tool that gives FFLs a competitive edge in acquisitions through superior data and automated forensic analysis.
