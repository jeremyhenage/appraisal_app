import vertexai
from vertexai.generative_models import GenerativeModel, Part, FinishReason
import vertexai.preview.generative_models as generative_models
import json
import logging
from typing import Optional, List
from models.models import AnalysisResult

# Initialize Vertex AI
# Note: valid_locations currently unused if we rely on ADC/Environment defaults, 
# but good to be explicit if needed. project_id is picked up from env.
vertexai.init()

logger = logging.getLogger(__name__)

def analyze_image(image_uri: str, ocr_text: Optional[List[str]] = None) -> AnalysisResult:
    """
    Analyzes an image using Gemini 1.5 Pro to identify the firearm and assess its condition.
    
    Args:
        image_uri: GCS URI (gs://...) or public URL of the image.
        ocr_text: Optional list of text strings detected by on-device OCR.
        
    Returns:
        AnalysisResult: Structured analysis of the firearm.
    """
    
    model = GenerativeModel("gemini-1.5-pro")
    
    # Construct the prompt
    ocr_context = ""
    if ocr_text:
        ocr_context = f"The following text was detected on the item via OCR: {', '.join(ocr_text)}."

    prompt = f"""
    You remain a forensic firearms expert. 
    Analyze the provided image of a firearm. {ocr_context}
    
    Your task is to:
    1. Identify the Make, Model, and specific Variant.
    2. Identify the Caliber if visible or standard for the model.
    3. Locate and transcribe the Serial Number if visible.
    4. Grade the condition based on NRA Modern Gun Condition Standards (New, Excellent, Very Good, Good, Fair, Poor).
    5. Determine if this specific configuration is likely 'Current Production' or out of production/vintage.
    6. List any visible modifications (aftermarket sights, grips, cerakote, etc.).
    7. Provide a confidence score (0.0 to 1.0) for your identification.

    Return the result strictly as a valid JSON object matching this schema:
    {{
        "make": "str",
        "model": "str",
        "variant": "str (or null)",
        "caliber": "str (or null)",
        "serial_number": "str (or null)",
        "condition_grade": "str",
        "is_current_production": bool,
        "modifications": ["str", ...],
        "confidence_score": float
    }}
    
    Do not include markdown formatting (```json) in the response, just the raw JSON string.
    """

    # Image Part
    # If image_uri is a GCS path, use Part.from_uri
    # If it's a web URL, we might need to fetch it first or use a different method.
    # For now, assuming GCS URI or we will implement URL handling if needed.
    # To be robust for the prototype, we assume the frontend uploads to GCS and passes the gs:// URI.
    
    if image_uri.startswith("gs://"):
        image_part = Part.from_uri(image_uri, mime_type="image/jpeg")
    elif image_uri.startswith("http"):
        # TODO: For HTTP URLs, we might need to download or use specific Vertex support.
        image_part = Part.from_uri(image_uri, mime_type="image/jpeg")
    else:
        # Assume local file path for testing
        try:
            with open(image_uri, "rb") as f:
                image_bytes = f.read()
                image_part = Part.from_data(image_bytes, mime_type="image/jpeg")
        except Exception as e:
            raise ValueError(f"Invalid image_uri: {image_uri}. Must be gs://, http://, or valid local path. Error: {e}")

    generation_config = {
        "max_output_tokens": 2048,
        "temperature": 0.2,
        "top_p": 0.8,
    }

    try:
        responses = model.generate_content(
            [image_part, prompt],
            generation_config=generation_config,
            stream=False,
        )
        
        response_text = responses.text.strip()
        # Clean up markdown if present despite instructions
        if response_text.startswith("```json"):
            response_text = response_text[7:]
        if response_text.endswith("```"):
            response_text = response_text[:-3]
            
        data = json.loads(response_text)
        
        return AnalysisResult(**data)
        
    except Exception as e:
        logger.error(f"Error during Gemini analysis: {e}")
        # Return a fallback or re-raise
        # For prototype, re-raising to see the error
        raise e
