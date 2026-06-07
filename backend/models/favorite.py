from sqlalchemy import Column, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.database import Base

class Favorite(Base):
    __tablename__ = "favorites"

    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False, primary_key=True)
    restaurant_id = Column(String(36), ForeignKey("restaurants.restaurant_id"), nullable=False, primary_key=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="favorites")
    restaurant = relationship("Restaurant", back_populates="favorites")