from pydantic import BaseModel
from typing import Optional, List

class ApiResponse(BaseModel):
    success: bool
    message: Optional[str] = None
    data: Optional[dict] = None