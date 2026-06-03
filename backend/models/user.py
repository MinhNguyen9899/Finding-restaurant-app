from sqlalchemy import Column, String, DateTime, Enum
from sqlalchemy.orm import relationship
from database import Base
from enum import Enum as pyEnum
from datetime import datetime, timezone

class UserRole(str, pyEnum):
    user = "user"
    admin = "admin"

class User(Base):
    __tablename__ = "users"

    user_id = Column(String(36), primary_key=True)

    user_name = Column(String(255), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)

    role = Column(Enum(UserRole), default=UserRole.user)

    created_at = Column(DateTime, default=datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=datetime.now(timezone.utc), onupdate=datetime.now(timezone.utc))

    reviews = relationship("Review", back_populates="user")
    favorites = relationship("Favorite", back_populates="user")
    contributions = relationship("Contribution", back_populates="user")
    search_history = relationship("SearchHistory", back_populates="user")