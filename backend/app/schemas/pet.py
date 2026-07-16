from decimal import Decimal
from pydantic import BaseModel

from .enums import Species, Gender, Size, EnergyLevel, PetStatus

class PetBase(BaseModel):
    name: str
    species: Species
    breed: str
    age: int
    gender: Gender
    size: Size
    energy_level: EnergyLevel
    description: str | None = None
    photo_url: str | None = None
    price: Decimal
    status: PetStatus = PetStatus.available
    category_id: int

class PetCreate(PetBase):
    pass

class PetUpdate(BaseModel):
    name: str | None = None
    species: Species | None = None
    breed: str | None = None
    age: int | None = None
    gender: Gender | None = None
    size: Size | None = None
    energy_level: EnergyLevel | None = None
    description: str | None = None
    photo_url: str | None = None
    price: Decimal | None = None
    status: PetStatus | None = None
    category_id: int | None = None

class PetOut(PetBase):
    id: int

    model_config = {"from_attributes": True}
