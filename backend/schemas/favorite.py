from pydantic import BaseModel
from datetime import datetime

class FavoriteResponse(BaseModel):
    user_id: str
    restaurant_id: str
    created_at: datetime

    class Config:
        from_attributes = True