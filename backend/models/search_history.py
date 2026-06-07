from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from backend.database import Base

class SearchHistory(Base):
    __tablename__ = "search_history"

    history_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False)
    keyword = Column(String(255), nullable=False)
    searched_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="search_history")