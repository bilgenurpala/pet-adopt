from decimal import Decimal
from typing import Annotated

from pydantic import BaseModel, Field

from .enums import Species, Gender, Size, EnergyLevel, PetStatus

PetAge = Annotated[Decimal, Field(max_digits=3, decimal_places=1, ge=0)]

class PetBase(BaseModel):
    name: str
    species: Species
    breed: str
    age: PetAge
    gender: Gender
    size: Size
    energy_level: EnergyLevel
    description: str | None = None
    photo_url: str | None = None
    adoption_fee: Decimal | None = None
    category_id: int

class PetCreate(PetBase):
    pass

class PetUpdate(BaseModel):
    name: str | None = None
    species: Species | None = None
    breed: str | None = None
    age: PetAge | None = None
    gender: Gender | None = None
    size: Size | None = None
    energy_level: EnergyLevel | None = None
    description: str | None = None
    photo_url: str | None = None
    adoption_fee: Decimal | None = None
    category_id: int | None = None

class PetOut(PetBase):
    id: int
    owner_id: int
    is_approved: bool
    status: PetStatus

    model_config = {"from_attributes": True}
