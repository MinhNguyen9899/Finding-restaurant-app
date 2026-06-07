from sqlalchemy import Column, String, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
from backend.database import Base
from enum import Enum as pyEnum
from backend.models.restaurant_category import restaurant_categories

class RestaurantStatus(str,pyEnum):
    OPEN = "open"
    CLOSED = "closed"
    PENDING = "pending" 

class Restaurant(Base):
    __tablename__ = "restaurants"

    restaurant_id = Column(String(36), primary_key=True)

    area_id = Column(Integer, ForeignKey("area.area_id"))

    restaurant_name = Column(String(255), nullable=False)
    address = Column(Text)
    phone = Column(String(15))
    description = Column(Text)

    latitude = Column(Float)
    longitude = Column(Float)

    price_range = Column(String(50))
    status = Column(
        Enum(RestaurantStatus),
        default=RestaurantStatus.OPEN)

    review_count = Column(Integer, default=0)
    average_rating = Column(Float, default=0.0)

    categories = relationship("Category", secondary=restaurant_categories, back_populates="restaurants")
    area = relationship("Area", back_populates="restaurants")
    reviews = relationship("Review", back_populates="restaurant")
    favorites = relationship("Favorite", back_populates="restaurant")
    contributions = relationship("Contribution", back_populates="restaurant")