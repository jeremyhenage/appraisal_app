# AppraisalApp — LLM Usage (Gemini 2.0 Flash)

> Grounded in `functions/services/analysis_service.py` as of commit `9f8c4fb`.

---

## Model

| Property    | Value                                             |
| ----------- | ------------------------------------------------- |
| Model ID    | `gemini-2.0-flash-exp`                            |
| Provider    | Google Vertex AI                                  |
| Region      | `us-central1`                                     |
| GCP Project | `firearmappraiser`                                |
| SDK         | `vertexai` Python SDK (`google-cloud-aiplatform`) |

**Why Flash over Pro?**

- Lower latency (critical for mobile UX — user is standing in front of a firearm)
- Lower cost per token
- Sufficient capability for structured JSON extraction from images
- Pro would be considered only if classification accuracy is insufficient in production

---

## When It's Called

Single call per appraisal. Triggered in:

```
functions/main.py → appraise_item()
  └── services/analysis_service.py → analyze_image(image_uri, ocr_text)
```

There is **no streaming**, **no multi-turn conversation**, and **no caching** in the current implementation.

---

## Generation Config

```python
generation_config = {
    "max_output_tokens": 2048,
    "temperature": 0.2,
    "top_p": 0.8,
}
```

| Parameter           | Value | Rationale                                                               |
| ------------------- | ----- | ----------------------------------------------------------------------- |
| `max_output_tokens` | 2048  | JSON response is bounded; prevents runaway generation and cost overrun  |
| `temperature`       | 0.2   | Low randomness → deterministic, factual identification output           |
| `top_p`             | 0.8   | Narrows token distribution for factual output; slight creative headroom |

---

## Input Construction

### Image Part

```python
if image_uri.startswith("gs://"):
    image_part = Part.from_uri(image_uri, mime_type="image/jpeg")
elif image_uri.startswith("http"):
    image_part = Part.from_uri(image_uri, mime_type="image/jpeg")
else:
    # Local file (testing only)
    image_part = Part.from_data(image_bytes, mime_type="image/jpeg")
```

**Preferred path:** `gs://` URI. The image is uploaded to Firebase Storage by the client, and the
`gs://` URI is passed to the Cloud Function. Vertex AI reads directly from GCS using the service
account — no base64 encoding, no HTTPS token management needed.

### OCR Context Injection

```python
ocr_context = ""
if ocr_text:
    ocr_context = f"The following text was detected on the item via OCR: {', '.join(ocr_text)}."
```

On-device ML Kit text recognition runs on the captured image before upload. Any detected text
(serial numbers, model markings, caliber stamps) is passed as context to the prompt. This
significantly improves identification accuracy for items where text is clearly visible.

> **Note:** OCR integration is wired in the backend but the frontend currently passes `ocr_text` as
> an empty list (the ML Kit call happens client-side but results are not yet plumbed through to the
> function call in `appraisal_repository.dart`). This is Phase 4 scope.

---

## Prompt Design

````
You remain a forensic firearms expert.
Analyze the provided image of a firearm. {ocr_context}

Your task is to:
1. Identify the Make, Model, and specific Variant.
2. Identify the Caliber if visible or standard for the model.
3. Locate and transcribe the Serial Number if visible.
4. Grade the condition based on NRA Modern Gun Condition Standards
   (New, Excellent, Very Good, Good, Fair, Poor).
5. Determine if this specific configuration is likely 'Current Production'
   or out of production/vintage.
6. List any visible modifications (aftermarket sights, grips, cerakote, etc.).
7. Provide a confidence score (0.0 to 1.0) for your identification.

Return the result strictly as a valid JSON object matching this schema:
{
    "make": "str",
    "model": "str",
    "variant": "str (or null)",
    "caliber": "str (or null)",
    "serial_number": "str (or null)",
    "condition_grade": "str",
    "is_current_production": bool,
    "modifications": ["str", ...],
    "confidence_score": float
}

Do not include markdown formatting (```json) in the response, just the raw JSON string.
````

**Prompt design decisions:**
| Choice | Rationale |
|---|---|
| "You remain a forensic firearms expert" | Establishes domain persona to bias towards technical precision |
| NRA condition grades explicitly listed | Constrains output to a known ontology; prevents free-form grade invention |
| `is_current_production` boolean | Key routing signal for valuation logic (RSR vs GunBroker path) |
| `confidence_score` float | Surfaces model uncertainty to the user; mapped to High/Medium/Low in frontend |
| "Raw JSON, no markdown" instruction | Prevents `\`\`\`json` fences; still stripped defensively in post-processing |
| Modifications as list | Captures aftermarket value modifiers for future pricing adjustments |

---

## Response Post-Processing

````python
response_text = responses.text.strip()

# Defensive strip of markdown fences (despite instruction)
if response_text.startswith("```json"):
    response_text = response_text[7:]
if response_text.endswith("```"):
    response_text = response_text[:-3]

data = json.loads(response_text)
return AnalysisResult(**data)
````

Pydantic validates the parsed JSON against `AnalysisResult`. If any required field is missing or
wrong type, a `ValidationError` is raised and caught by `main.py`'s generic error handler.

---

## Retry Strategy

```python
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from google.api_core.exceptions import ResourceExhausted

@retry(
    retry=retry_if_exception_type(ResourceExhausted),
    stop=stop_after_attempt(5),
    wait=wait_exponential(multiplier=2, min=2, max=30)
)
def generate_with_retry(model, parts, config):
    return model.generate_content(...)
```

| Parameter       | Value                                         |
| --------------- | --------------------------------------------- |
| Retry condition | `ResourceExhausted` (429 quota exceeded) only |
| Max attempts    | 5                                             |
| Backoff         | Exponential: 2s, 4s, 8s, 16s, 30s (capped)    |
| Other errors    | Not retried — propagated immediately          |

**Why only `ResourceExhausted`?**

- Quota limits are transient; brief backoff resolves them
- Other errors (invalid input, auth failure, model error) won't be fixed by retrying

---

## Output → Frontend Mapping

The backend `AnalysisResult` fields are consumed by `AppraisalResult.fromJson()` in Dart:

| Backend Field                    | Frontend Field   | Transform                                      |
| -------------------------------- | ---------------- | ---------------------------------------------- |
| `analysis.make`                  | `make`           | Direct string copy                             |
| `analysis.model`                 | `model`          | Direct string copy                             |
| `analysis.is_current_production` | `liquidityScore` | `true` → "High", `false` → "Medium"            |
| `valuation.valuation_confidence` | `confidence`     | `≥0.9` → "High", `≥0.7` → "Medium", else "Low" |
| `valuation.wholesale_price`      | `minPrice`       | Falls back to `estimated_value * 0.8`          |
| `valuation.map_price`            | `maxPrice`       | Falls back to `estimated_value * 1.2`          |
| `valuation.comparables`          | `comparables`    | `List<dynamic>` cast to `List<String>`         |

Fields in `AnalysisResult` that are **not yet surfaced** in the frontend:

- `variant` — available, not displayed
- `caliber` — available, not displayed
- `serial_number` — available, not displayed
- `condition_grade` — available, not displayed
- `modifications` — available, not displayed

These will be valuable additions to the Deal Dashboard in Phase 4.

---

## Cost Considerations

| Factor                 | Current Approach                                          |
| ---------------------- | --------------------------------------------------------- |
| Calls per user session | 1 (no multi-turn, no retries unless quota hit)            |
| Image transfer         | GCS URI (no base64, minimal overhead)                     |
| Token budget           | 2048 output max; input ~500 tokens (prompt + small image) |
| Model                  | Flash (cheapest multimodal Vertex model)                  |
| Rate limiting          | ❌ None — quota is the only ceiling                       |
| Caching                | ❌ None — same image scanned twice = two API calls        |

> **Phase 4 recommendation:** Add per-user call rate limiting in the Cloud Function
> (check a Firestore counter per UID before calling Vertex AI).
