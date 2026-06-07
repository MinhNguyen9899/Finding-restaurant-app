from sqlalchemy import Column, Integer, ForeignKey, Table, String
from backend.database import Base

restaurant_categories = Table(
    "restaurant_categories",
    Base.metadata,
    
    Column("restaurant_id", String(36), ForeignKey("restaurants.restaurant_id"), primary_key=True),
    Column("category_id", ForeignKey("categories.category_id"), primary_key=True)
)