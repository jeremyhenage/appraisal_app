# AppraisalApp — Backend Module Map

> Python Cloud Functions backend reference as of commit `9f8c4fb`.  
> Runtime: Python 3.11 · Framework: `firebase-functions` v0.1+ · Region: `us-central1`

---

## Directory Structure

```
functions/
├── main.py                    ← Function entry point + auth guard
├── requirements.txt           ← Python dependencies
├── __init__.py
├── models/
│   ├── __init__.py
│   └── models.py              ← Pydantic data schemas
└── services/
    ├── __init__.py
    ├── analysis_service.py    ← Gemini image analysis
    └── valuation_service.py   ← Pricing logic
```

---

## Module Responsibility Map

| Module                          | Owns                                                         | Does NOT Own         |
| ------------------------------- | ------------------------------------------------------------ | -------------------- |
| `main.py`                       | Function registration, auth, request routing, error wrapping | Business logic       |
| `models/models.py`              | Data shapes and validation                                   | I/O or API calls     |
| `services/analysis_service.py`  | Gemini API call, image parsing, retry                        | Valuation, auth      |
| `services/valuation_service.py` | Pricing logic, source routing                                | Image analysis, auth |

---

## `main.py` — Entry Point

### Registered Functions

| Function Name   | Trigger        | Region        | Memory |
| --------------- | -------------- | ------------- | ------ |
| `appraise_item` | HTTPS Callable | `us-central1` | 512 MB |

### Request Flow

```
Client SDK → appraise_item(CallableRequest)
  │
  ├── Validate: data['imageUrl'] present?
  │     └── No → HttpsError(INVALID_ARGUMENT)
  │
  ├── Auth check: request.auth present?
  │     └── No → HttpsError(UNAUTHENTICATED)
  │
  ├── analyze_image(image_url, ocr_text) → AnalysisResult
  │
  ├── get_valuation(analysis_result) → ValuationResult
  │
  ├── AppraisalResponse(analysis, valuation) → .model_dump(mode='json')
  │
  └── return dict (Firebase SDK wraps as JSON)
```

### Error Handling

All unhandled exceptions are caught and re-raised as `HttpsError(INTERNAL)` with the
exception message. This means exception messages reach the client — acceptable for debug,
but consider sanitizing for production to avoid leaking internal details.

### Lazy Imports

Services are imported inside the function body (not at module top) to minimize cold-start time:

```python
from services.analysis_service import analyze_image
from services.valuation_service import get_valuation
from models.models import AppraisalResponse
```

---

## `models/models.py` — Pydantic Schemas

### `AppraisalRequest`

Input shape. Currently not used as a validator in `main.py` — validated manually instead.

```python
image_url: str             # GCS or HTTP URL
ocr_text: Optional[List[str]]  # On-device OCR results
user_context: Optional[dict]   # User-supplied seeds (e.g. "Pre-64 Winchester")
```

### `AnalysisResult` — Gemini Output

```python
make: str
model: str
variant: Optional[str]
caliber: Optional[str]
serial_number: Optional[str]
condition_grade: str        # NRA: New | Excellent | Very Good | Good | Fair | Poor
is_current_production: bool # Key routing signal for valuation
modifications: List[str]    # Aftermarket parts observed
confidence_score: float     # 0.0–1.0
```

### `ValuationResult` — Pricing Output

```python
source: Literal["RSR", "GunBroker", "Hybrid"]
wholesale_price: Optional[float]
map_price: Optional[float]
estimated_value: float      # Final price estimate
currency: str = "USD"
comparables: List[str]      # Source URLs or labels
valuation_confidence: float # 0.0–1.0
```

### `AppraisalResponse` — Final Return

```python
analysis: AnalysisResult
valuation: ValuationResult
timestamp: datetime         # UTC, auto-set
```

Returned via `.model_dump(mode='json')` — datetime serialized as ISO string.

---

## `services/analysis_service.py` — Gemini Integration

### Public API

```python
def analyze_image(image_uri: str, ocr_text: Optional[List[str]] = None) -> AnalysisResult
```

### Vertex AI Config

```python
vertexai.init(project="firearmappraiser", location="us-central1")
model = GenerativeModel("gemini-2.0-flash-exp")
```

### Image URI Handling

| URI Prefix              | Handling                                                      |
| ----------------------- | ------------------------------------------------------------- |
| `gs://`                 | `Part.from_uri(uri, mime_type="image/jpeg")` — preferred path |
| `http://` or `https://` | `Part.from_uri(uri, ...)` — Vertex fetches directly           |
| Other (local path)      | `Part.from_data(bytes, ...)` — testing only                   |

### Generation Config

```python
{
    "max_output_tokens": 2048,
    "temperature": 0.2,
    "top_p": 0.8,
}
```

### Retry Decorator

```python
@retry(
    retry=retry_if_exception_type(ResourceExhausted),
    stop=stop_after_attempt(5),
    wait=wait_exponential(multiplier=2, min=2, max=30)
)
```

Handles quota exhaustion (429). Other errors are not retried.

### Response Pipeline

````
model.generate_content([image_part, prompt])
  → responses.text.strip()
  → strip ```json fences (defensive)
  → json.loads(response_text)
  → AnalysisResult(**data)  ← Pydantic validates
````

---

## `services/valuation_service.py` — Pricing Logic

### Public API

```python
def get_valuation(analysis: AnalysisResult) -> ValuationResult
```

### Routing Decision

```python
if analysis.is_current_production:
    return _query_rsr_group_mock(analysis)   # Current production → wholesale/MAP pricing
else:
    return _scrape_gunbroker(analysis)       # Vintage/OOP → completed listing pricing
```

### `_query_rsr_group_mock()` — Current Production Path

> ⚠️ **MOCKED** — Phase 4 will replace with real RSR Group API call.

Current logic: deterministic mock price based on model name character count.

```python
base_price = 500.0 + (len(analysis.model) * 50)
value = base_price if condition == "New" else base_price * 0.7
```

Returns: `wholesale_price = base * 0.8`, `map_price = base * 1.2`, `valuation_confidence = 0.9`

### `_scrape_gunbroker()` — Vintage Path

> ⚠️ **MOCKED** — Phase 4 will implement real scraping or GunBroker API.

Current logic: hardcoded values by condition grade.

```python
if condition == "Excellent": estimated_value = 1200.0
elif condition == "Good":    estimated_value = 800.0
else:                        estimated_value = 800.0  # default
```

Returns: `source = "GunBroker"`, `valuation_confidence = 0.7`

---

## `requirements.txt`

```
firebase-functions     # Callable function framework
firebase-admin         # Admin SDK (initialize_app, Firestore if needed)
vertexai               # Vertex AI Python SDK (Gemini)
google-cloud-aiplatform # Underlying platform SDK
pydantic>=2.0          # Data validation and serialization
tenacity               # Retry logic
requests               # HTTP client (GunBroker scraping placeholder)
beautifulsoup4         # HTML parsing (GunBroker scraping placeholder)
```

---

## Adding a New Cloud Function

1. Define Pydantic models in `models/models.py`
2. Add business logic in a new `services/<name>_service.py`
3. Register the function in `main.py` with `@https_fn.on_call(region="us-central1")`
4. Add auth check: `if not request.auth: raise HttpsError(UNAUTHENTICATED, ...)`
5. Add lazy imports inside the function body
6. Add Python tests in `tests/services/test_<name>_service.py`
7. Register in `firebase.json` `functions.source` if needed

---

## Testing Structure

```
tests/
├── test_analysis_service.py    # Mock Vertex AI; test prompt construction and response parsing
├── test_valuation_service.py   # Test routing logic, mock return values
└── test_main.py                # Test auth guard, missing fields, error propagation
```

> ⚠️ Test coverage is minimal. See `docs/phases/phase_4_plan.md` for testing roadmap.

---

## Local Development

```bash
cd functions/
source venv/bin/activate
# Start Firebase emulator
firebase emulators:start --only functions

# Or deploy directly
firebase deploy --only functions
```

The Cloud Function uses Application Default Credentials. For local dev:

```bash
gcloud auth application-default login
```
