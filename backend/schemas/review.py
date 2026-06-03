from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class ReviewCreate(BaseModel):
    user_id: str
    restaurant_id: str
    rating: int = Field(..., ge=1, le=5)  # Đảm bảo rating nằm trong khoảng 1-5
    comment: Optional[str] = None

class ReviewResponse (BaseModel):
    review_id: str
    user_id: str
    restaurant_id: str
    rating: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True