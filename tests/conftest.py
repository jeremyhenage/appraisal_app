import pytest
import os
import json
from pathlib import Path

@pytest.fixture
def golden_set_path():
    """Returns the path to the golden_set directory."""
    return Path(__file__).parent / "golden_set"

@pytest.fixture
def ground_truth(golden_set_path):
    """Loads the ground_truth.json file."""
    with open(golden_set_path / "ground_truth.json", "r") as f:
        return json.load(f)

@pytest.fixture
def mock_rsr_api(mocker):
    """Mocks the RSR Group API response."""
    # This will be replaced by vcrpy later or enhanced
    return mocker.patch("functions.services.valuation_service.query_rsr_group")

@pytest.fixture
def mock_gunbroker_scraper(mocker):
    """Mocks the GunBroker scraper."""
    # This will be replaced by vcrpy later or enhanced
    return mocker.patch("functions.services.valuation_service.scrape_gunbroker")
