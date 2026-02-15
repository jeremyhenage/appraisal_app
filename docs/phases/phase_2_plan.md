# Implementation Plan - Phase 2: Backend Logic

## Goal Description

Implement the core "Brain" of the application using Google Cloud Functions. This includes the `analyze` function (using Gemini 1.5 Pro via Vertex AI) and the `valuation` function (orchestrating RSR Group and GunBroker data).

## User Review Required

> [!IMPORTANT]
> We will use `gemini-1.5-pro-preview-0409` (or similar latest) for the `analyze` function to ensure high fidelity. Ensure your GCP project has Vertex AI API enabled.

## Proposed Changes

### Data Models

#### [NEW] [models.py](file:///Users/jeremy/Documents/projects/AppraisalApp/functions/models/models.py)

- Pydantic models for `AppraisalRequest`, `AnalysisResult`, `ValuationResult`, and `AppraisalResponse`.
- Ensures type safety and clear API contracts.

### Services

#### [NEW] [analysis_service.py](file:///Users/jeremy/Documents/projects/AppraisalApp/functions/services/analysis_service.py)

- `analyze_image(image_bytes)`: Sends image to Vertex AI Gemini.
- Uses the "Forensic Analysis" prompt strategy defined in the PRD.
- Returns structured JSON.

#### [MODIFY] [valuation_service.py](file:///Users/jeremy/Documents/projects/AppraisalApp/functions/services/valuation_service.py)

- Implement `get_valuation(analysis_result)`.
- **RSR Group**: Mocked implementation (returning fixed wholesale/MAP).
- **GunBroker**: Scraper implementation (using `requests` + `beautifulsoup4`) with Gemini 1.5 Flash for parsing unstructured HTML results.

### Entry Points

#### [MODIFY] [main.py](file:///Users/jeremy/Documents/projects/AppraisalApp/functions/main.py)

- `on_analyze_request`: HTTPS Callable function.
- Orchestrates: Request -> Analysis Service -> Valuation Service -> Response.

## Verification Plan

### Automated Tests

- Update `tests/test_valuation.py` to use the real service functions (mocked at the network layer).
- Run `pytest` to verify the pipeline flows correctly.
