from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List
from enum import Enum

class RestaurantStatus(str, Enum):
    open = "open"
    closed = "closed"
    
# Định nghĩa schema cho Restaurant
class RestaurantCreate(BaseModel):
    restaurant_name: str
    address: Optional[str] = None
    phone: Optional[str] = None
    description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    price_range: Optional[str] = None
    status: Optional[RestaurantStatus] = None
    category_ids: List[int] = Field(default_factory=list)
    area_id: Optional[int] = None

# Định nghĩa schema trả về cho Restaurant
class RestaurantResponse(BaseModel):
    restaurant_id: str
    restaurant_name: str
    address: Optional[str] = None
    phone: Optional[str] = None
    description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    price_range: Optional[str] = None
    status: Optional[RestaurantStatus] = None
    review_count: int = 0
    average_rating: float = 0.0
    category_ids: List[str]
    area_id: Optional[int] = None

    model_config = {"from_attributes": True}

class RestaurantUpdate(BaseModel):
    restaurant_name: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    price_range: Optional[str] = None
    status: Optional[RestaurantStatus] = None
    category_ids: Optional[List[int]] = None
    area_id: Optional[int] = None

    model_config = ConfigDict(from_attributes=True)


class RestaurantListResponse(BaseModel):
    restaurant_id: str
    restaurant_name: str
    address: Optional[str] = None
    phone: Optional[str] = None
    category_ids: List[str]
    area_id: Optional[int] = None

    model_config = ConfigDict(from_attributes=True)