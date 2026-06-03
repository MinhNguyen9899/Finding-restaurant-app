from pydantic import BaseModel
from datetime import datetime

class SearchHistoryResponse(BaseModel):
    history_id: str
    user_id: str
    keyword: str
    created_at: datetime

    model_config = {"from_attributes": True}

class SearchHistoryCreate(BaseModel):
    keyword: str
    user_id:int