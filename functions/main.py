import functions_framework
from flask import jsonify
import logging
import json
from services.analysis_service import analyze_image
from services.valuation_service import get_valuation
from models.models import AppraisalResponse

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def on_analyze_request(request):
    """
    HTTP Cloud Function for Image Analysis using Vertex AI.
    Orchestrates: Request -> Analysis Service -> Valuation Service -> Response
    """
    # Set CORS headers for the preflight request
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    # Set CORS headers for the main request
    headers = {
        'Access-Control-Allow-Origin': '*'
    }

    try:
        request_json = request.get_json(silent=True)
        if not request_json or 'imageUrl' not in request_json:
            return (jsonify({"error": "Missing imageUrl in request body"}), 400, headers)

        image_url = request_json['imageUrl']
        ocr_text = request_json.get('ocrText', [])
        user_context = request_json.get('userContext', {})

        logger.info(f"Received analysis request for {image_url}")

        # 1. Analyze Image (Gemini)
        analysis_result = analyze_image(image_url, ocr_text)
        logger.info(f"Analysis complete: {analysis_result.make} {analysis_result.model}")

        # 2. Valuation (RSR/GunBroker)
        valuation_result = get_valuation(analysis_result)
        logger.info(f"Valuation complete: ${valuation_result.estimated_value}")

        # 3. Construct Response
        response = AppraisalResponse(
            analysis=analysis_result,
            valuation=valuation_result
        )

        return (jsonify(response.model_dump(mode='json')), 200, headers)

    except Exception as e:
        logger.error(f"Error processing request: {e}", exc_info=True)
        return (jsonify({"error": str(e)}), 500, headers)
