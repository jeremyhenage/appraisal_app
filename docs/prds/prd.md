Project "Operator": Firearm Valuation & Acquisition System
Role: You are a Staff Engineer and UI/UX Designer specializing in Flutter and Python serverless architectures.
Goal: Build a high-fidelity mobile application for rapid firearm identification and valuation. The priority is precision and depth of analysis over minimizing compute costs.
Target Audience: Domain experts (FFLs) who need "Check and Balance" valuation in the field.

1. Technical Architecture (The Stack)
   Frontend: Flutter (Dart).

State Management: Riverpod or Bloc (Your choice, but keep it clean).

ML: google_ml_kit_text_recognition (On-device OCR).

UI Libs: google_fonts, flutter_animate, flex_color_scheme.

Backend: Google Firebase.

Auth: Firebase Auth (Anonymous + Email/Link).

Database: Cloud Firestore (NoSQL).

Backend Logic: Cloud Functions (2nd Gen) running Python 3.11+.

Storage: Firebase Storage (Images).

AI / Intelligence:

Vision & Reasoning: Vertex AI (Gemini 3 Pro). Note: Use the rigorous "Forensic Analysis" prompt strategy.

Orchestration: LangChain or simple Python async functions.

External Data:

Distributors: RSR Group API (Mock this for now with a JSON response), Lipsey's API.

Market Data: GunBroker "Sold" Listings (Scraping via Python requests/beautifulsoup or similar).

Testing & QA:

Framework: pytest + vcrpy (for recording/mocking API responses).

Strategy: "Golden Set" Evaluation. We test against a folder of known images/values to ensure accuracy.

2. UI/UX Design System: "Tactical Dark"
   Aesthetic: High-contrast, industrial sci-fi (think "Blade Runner" or a tactical data terminal).
   Strict Design Rules:

Surface: Deep Matte Grey (#121212) & Card Surface (#1E1E1E).

Primary Accent: Neon Cyan (#00E5FF) for primary actions (Scan, Analyze).

Success/Profit: Matrix Green (#00FF41) for high confidence/profit.

Warning/Risk: Bitcrush Red (#FF0055) for low liquidity or issues.

Typography:

Headers/Data: JetBrains Mono (Technical feel).

Body: Inter (Readability).

Components: Sharp corners (BorderRadius.circular(4)), thin 1px borders (#333333), and "glitch" or slide-in animations on load.

3. Functional Requirements (The Workflow)
   Phase 1: The "Deep Scan" (Flutter)
   Camera View: Real-time camera feed with a "Targeting Reticle" overlay (Cyan).

OCR Layer: Real-time text detection. Detected text blocks should be highlighted with Green bounding boxes.

Interaction: User taps detected text (e.g., "Model 70", "S/N 12345") to "Lock" it into a chip list.

Seeding: A text input/chip selector for user context (e.g., "Pre-64", "Rough Condition").

Action: "Analyze" button captures the image + locked text + seeds and sends to Backend.

Phase 2: The "Forensic Analyst" (Python Cloud Function)
Endpoint: on_analyze_request (Callable Function).

Step 1: Identification (Gemini 3 Pro):

Prompt: "Analyze image + OCR text. Verify identity. Grade condition (NRA Standards). Identify modifications."

Output: JSON with make, model, variant, condition_grade, is_current_production (Boolean).

Phase 3: The "Bifurcated" Valuation Engine (Python)
Logic:

IF is_current_production == True:

Query RSR Group API (Mocked).

Get wholesale_price and map_price.

Valuation: Wholesale \* 0.8.

Retail Benchmark: Return map_price as "Est. Street Price".

IF is_current_production == False:

Generate optimized search terms (e.g., "Winchester 94 Pre-64").

Scrape GunBroker Completed/Sold listings.

Use Gemini 3 Flash to parse/clean the raw HTML results (remove outliers).

Valuation: Average of valid sold listings.

Phase 4: The "Deal Dashboard" (Flutter)
Display: A "Deal Card" showing:

Identity: Make/Model/Variant (JetBrains Mono).

Condition: Grade (e.g., "85% - Very Good").

Valuation: Large text. Green if confident, Yellow if variable.

Retail Benchmark: (If new) "Street Price: $X (MAP)".

Liquidity: Traffic Light (Green/Yellow/Red) based on sales velocity.

4. Implementation Steps (Execution Order)
   Setup: Initialize the Flutter app and Firebase project (Functions + Firestore).

The "Golden Set" (Critical): Create tests/golden_set/ with 3 sample images and a ground_truth.json. Write the pytest harness using vcrpy to mock the Gemini/RSR APIs. Do not proceed until tests pass against mocks.

Backend Logic: Write the Python Cloud Functions for analyze and valuation. Implement the RSR Mock and GunBroker scraper logic.

Frontend UI: Build the "Tactical Dark" theme and the Camera/OCR screen.

Integration: Connect the Flutter app to the Cloud Functions.

Immediate Task:
Start by setting up the Python Testing Framework (Step 2). Create the ground_truth.json and the test_valuation.py script. I want to see the "Brain" working against known data before we build the UI.
