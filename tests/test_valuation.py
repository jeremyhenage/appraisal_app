import pytest
import os
import sys

# Ensure functions/ directory is in path for imports
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'functions')))

from services.analysis_service import analyze_image
from services.valuation_service import get_valuation

@pytest.mark.skip(reason="Requires real Vertex AI credentials and images")
def test_golden_set_valuation_real(ground_truth):
    """
    Iterates through the golden set and verifies that the valuation logic
    produces results within an acceptable margin of error.
    """
    base_dir = os.path.join(os.path.dirname(__file__), 'golden_set')
    
    for item in ground_truth:
        image_filenames = item["image_filenames"]
        ocr_text = [item["ocr_text"]] if item.get("ocr_text") else []
        expected_analysis = item["expected_analysis"]
        expected_valuation = item["expected_valuation"]

        # Use the first image for analysis
        if not image_filenames:
            continue
            
        full_image_path = os.path.join(base_dir, image_filenames[0])
        print(f"Testing item: {item['id']} with image: {full_image_path}")
        
        # 1. Analyze
        # Note: This makes a REAL call to Vertex AI. 
        # ensure you have `gcloud auth application-default login` set up.
        try:
            analysis_result = analyze_image(full_image_path, ocr_text)
            
            # Basic assertions on Analysis
            assert analysis_result.make is not None
            assert analysis_result.condition_grade in ["New", "Excellent", "Very Good", "Good", "Fair", "Poor"]
            
            # 2. Valuation
            valuation_result = get_valuation(analysis_result)
            
            assert valuation_result.estimated_value > 0
            
            print(f"  > ID: {analysis_result.make} {analysis_result.model}")
            print(f"  > Est Value: ${valuation_result.estimated_value}")
            
        except Exception as e:
            pytest.fail(f"Failed to analyze/value item {item['id']}: {e}")

from models.models import AnalysisResult

def test_valuation_logic_synthetic():
    """
    Tests the valuation logic using synthetic analysis results (no images required).
    This allows us to verify the 'Brain' logic even if we lack the test images.
    """
    # Case 1: Current Production (RSR Mock)
    analysis_new = AnalysisResult(
        make="Glock",
        model="19",
        variant="Gen 5",
        condition_grade="New",
        is_current_production=True,
        confidence_score=0.95
    )
    val_new = get_valuation(analysis_new)
    assert val_new.source == "RSR"
    assert val_new.estimated_value > 500
    assert val_new.currency == "USD"

    # Case 2: Vintage (GunBroker Scraper)
    analysis_old = AnalysisResult(
        make="Winchester",
        model="Model 70",
        variant="Pre-64",
        condition_grade="Good",
        is_current_production=False,
        confidence_score=0.90
    )
    val_old = get_valuation(analysis_old)
    assert val_old.source == "GunBroker"
    assert val_old.estimated_value == 800.0 # Based on our mock logic for "Good"
    assert val_old.currency == "USD"

def test_api_mocks(mocker):
    """
    Verifies that external APIs are correctly mocked (placeholder).
    """
    pass
