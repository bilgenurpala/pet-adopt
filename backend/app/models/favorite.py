from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base


class Favorite(Base):
    __tablename__ = "favorites"

    user_id = Column(Integer, ForeignKey("user.id"), primary_key=True, nullable=False)
    pet_id = Column(Integer, ForeignKey("pet.id"), primary_key=True, nullable=False)

    user = relationship("User")
    pet = relationship("Pet")
