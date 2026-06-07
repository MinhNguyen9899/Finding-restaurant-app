from sqlalchemy import Column, String, DateTime, Enum, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.database import Base
from enum import Enum as PyEnum

class ContributionType(str, PyEnum):
    ADD_RESTAURANT = "add_restaurant"
    UPDATE_INFO = "update_info"
    REPORT_CLOSED = "report_closed"

class ContributionStatus(str, PyEnum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"

class Contribution(Base):
    __tablename__ = "contributions"

    contribution_id = Column(String(36), primary_key=True)

    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    restaurant_id = Column(String(36), ForeignKey("restaurants.restaurant_id"), nullable=False)

    contribution_type = Column(Enum(ContributionType), nullable=False)
    old_data = Column(Text)
    new_data = Column(Text)

    status = Column(Enum(ContributionStatus), default=ContributionStatus.PENDING)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="contributions")
    restaurant = relationship("Restaurant", back_populates="contributions")

