from sqlalchemy import Column, String, ForeignKey, Integer
from sqlalchemy.orm import relationship
from backend.database import Base

class Area(Base):
    __tablename__ = "area"

    area_id = Column(Integer, primary_key=True, autoincrement=True)
    area_name = Column(String(255), nullable=False)
    parent_area_id = Column(Integer, ForeignKey("area.area_id"))

    restaurants = relationship("Restaurant", back_populates="area")
    parent = relationship("Area", remote_side=[area_id], backref="sub_areas")