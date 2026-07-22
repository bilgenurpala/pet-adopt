from sqlalchemy import Column, Integer, String, Boolean, Numeric, ForeignKey, Enum
from sqlalchemy import false as sa_false
from sqlalchemy.orm import relationship
from app.database import Base
from .enums import Species, Gender, Size, EnergyLevel, PetStatus


class Pet(Base):
    __tablename__ = "pet"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    species = Column(Enum(Species, values_callable=lambda e: [i.value for i in e]), nullable=False)
    breed = Column(String, nullable=False)
    age = Column(Numeric(precision=3,scale=1), nullable=False)
    gender = Column(Enum(Gender, values_callable=lambda e: [i.value for i in e]), nullable=False)
    size = Column(Enum(Size, values_callable=lambda e: [i.value for i in e]), nullable=False)
    energy_level = Column(Enum(EnergyLevel, values_callable=lambda e: [i.value for i in e]), nullable=False)
    description = Column(String, nullable=True)
    photo_url = Column(String, nullable=True)
    adoption_fee = Column(Numeric(10, 2), nullable=True)

    status = Column(Enum(PetStatus, values_callable=lambda e: [i.value for i in e]), nullable=False,
                    default=PetStatus.AVAILABLE, server_default=PetStatus.AVAILABLE.value)
    owner_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("category.id"), nullable=False)

    is_approved = Column(Boolean, nullable=False, default=False, server_default=sa_false())

    owner = relationship(
        "User",
        back_populates="pets",
    )
    category = relationship(
        "Category",
        back_populates="pets",
    )
