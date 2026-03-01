from firebase_functions import https_fn, options
from firebase_admin import initialize_app
from flask import jsonify
import logging
import json
from typing import Any


# Initialize Firebase Admin
initialize_app()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@https_fn.on_call(region="us-central1", memory=512)
def appraise_item(request: https_fn.CallableRequest) -> Any:
    """
    Callable Cloud Function for Image Analysis.
    Automatically handles Auth and CORS.
    """
    # Lazy imports to speed up cold start and discovery
    from services.analysis_service import analyze_image
    from services.valuation_service import get_valuation
    from models.models import AppraisalResponse

    # 1. Access Data directly (CallableRequest.data is the payload)
    data = request.data
    
    if not data or 'imageUrl' not in data:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="Missing imageUrl in request data"
        )

    image_url = data['imageUrl']
    ocr_text = data.get('ocrText', [])
    
    # User context is automatically available in request.auth if needed
    # user_id = request.auth.uid if request.auth else None

    # SECURITY CHECK: Ensure user is authenticated
    if not request.auth:
        logger.warning("Unauthenticated request blocked")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="You must be signed in to usage this feature."
        )

    logger.info(f"Received analysis request for {image_url} from user {request.auth.uid}")

    try:
        # 2. Analyze Image (Gemini)
        analysis_result = analyze_image(image_url, ocr_text)
        logger.info(f"Analysis complete: {analysis_result.make} {analysis_result.model}")

        # 3. Valuation (RSR/GunBroker)
        valuation_result = get_valuation(analysis_result)
        logger.info(f"Valuation complete: ${valuation_result.estimated_value}")

        # 4. Construct Response (Return raw dict/object, SDK handles JSON wrapping)
        response_model = AppraisalResponse(
            analysis=analysis_result,
            valuation=valuation_result
        )
        
        return response_model.model_dump(mode='json')

    except Exception as e:
        logger.error(f"Error processing request: {e}", exc_info=True)
        # Throw specific HttpsError for the client to parse
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message=str(e)
        )
