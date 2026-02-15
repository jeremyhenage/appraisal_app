import requests
from bs4 import BeautifulSoup
import logging
import random
from models.models import AnalysisResult, ValuationResult

logger = logging.getLogger(__name__)

def get_valuation(analysis: AnalysisResult) -> ValuationResult:
    """
    Determines the value of the firearm based on its analysis.
    Logic:
    - If current production: Use RSR Group (Mock) wholesale/MAP.
    - If vintage/out of production: Use GunBroker (Scrape) completed listings.
    """
    
    if analysis.is_current_production:
        return _query_rsr_group_mock(analysis)
    else:
        return _scrape_gunbroker(analysis)

def _query_rsr_group_mock(analysis: AnalysisResult) -> ValuationResult:
    """
    Mocks a query to the RSR Group API for current production items.
    """
    logger.info(f"Querying RSR Group (Mock) for {analysis.make} {analysis.model}")
    
    # Mock logic: Generate a price based on a hash of the model name to be consistent but fake
    base_price = 500.0 + (len(analysis.model) * 50) 
    if analysis.condition_grade == "New":
        value = base_price
    else:
        # Depreciate for used
        value = base_price * 0.7
        
    return ValuationResult(
        source="RSR",
        wholesale_price=base_price * 0.8,
        map_price=base_price * 1.2,
        estimated_value=value,
        currency="USD",
        comparables=["http://rsrgroup.com/mock-item"],
        valuation_confidence=0.9
    )

def _scrape_gunbroker(analysis: AnalysisResult) -> ValuationResult:
    """
    Scrapes GunBroker for completed listings. 
    Note: Real scraping is fragile. This is a simplified implementation.
    """
    search_term = f"{analysis.make} {analysis.model} {analysis.variant or ''}".strip()
    logger.info(f"Scraping GunBroker for: {search_term}")
    
    # In a real implementation:
    # url = f"https://www.gunbroker.com/Completed/search?Keywords={search_term}&TimeFrame=1"
    # response = requests.get(url)
    # soup = BeautifulSoup(response.content, 'html.parser')
    # ... parse sold prices ...
    
    # Mocking the scraper result for stability in this phase
    # TODO: Implement actual scraping with Gemini Flash parsing if needed for "Forensic Analyst" phase
    
    estimated_value = 800.0 # Placeholder
    if analysis.condition_grade == "Excellent":
        estimated_value = 1200.0
    elif analysis.condition_grade == "Good":
        estimated_value = 800.0
        
    return ValuationResult(
        source="GunBroker",
        estimated_value=estimated_value,
        currency="USD",
        comparables=[f"https://www.gunbroker.com/item/123456 (Mock)"],
        valuation_confidence=0.7
    )
