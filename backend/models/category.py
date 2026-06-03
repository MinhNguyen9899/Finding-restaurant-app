from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from models.restaurant_category import restaurant_categories
from database import Base

class Category(Base):
    __tablename__ = "categories"

    category_id = Column(Integer, primary_key=True, autoincrement=True)
    category_name = Column(String(255), nullable=False)

    restaurants = relationship("Restaurant", secondary=restaurant_categories, back_populates="categories")