from pydantic import BaseModel, Field
from typing import List, Optional, Literal
from datetime import datetime

class AppraisalRequest(BaseModel):
    image_url: str = Field(..., description="GCS or HTTP URL of the image to analyze")
    ocr_text: Optional[List[str]] = Field(default=None, description="Text detected by on-device OCR")
    user_context: Optional[dict] = Field(default=None, description="User provided context seeds (e.g. 'Pre-64')")

class AnalysisResult(BaseModel):
    make: str
    model: str
    variant: Optional[str] = None
    caliber: Optional[str] = None
    serial_number: Optional[str] = None
    condition_grade: str = Field(..., description="NRA Condition Grade")
    is_current_production: bool
    modifications: List[str] = Field(default_factory=list)
    confidence_score: float = Field(..., ge=0.0, le=1.0)

class ValuationResult(BaseModel):
    source: Literal["RSR", "GunBroker", "Hybrid"]
    wholesale_price: Optional[float] = None
    map_price: Optional[float] = None
    estimated_value: float = Field(..., description="Final estimated value")
    currency: str = "USD"
    comparables: List[str] = Field(default_factory=list, description="List of comparable listings or sources")
    valuation_confidence: float = Field(..., ge=0.0, le=1.0)

class AppraisalResponse(BaseModel):
    analysis: AnalysisResult
    valuation: ValuationResult
    timestamp: datetime = Field(default_factory=datetime.utcnow)
