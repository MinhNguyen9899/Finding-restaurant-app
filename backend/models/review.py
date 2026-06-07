from sqlalchemy import Column, String, Text, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.database import Base
import uuid

class Review(Base):
    __tablename__ = "reviews"

    review_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))

    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    restaurant_id = Column(String(36), ForeignKey("restaurants.restaurant_id"), nullable=False)

    rating = Column(Integer, nullable=False)
    comment = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="reviews")
    restaurant = relationship("Restaurant", back_populates="reviews")