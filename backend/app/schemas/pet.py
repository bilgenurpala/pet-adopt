from decimal import Decimal
from typing import Annotated

from pydantic import BaseModel, Field

from .enums import Species, Gender, Size, EnergyLevel, PetStatus

# Mirrors the DB column Numeric(3, 1): max 99.9, one decimal place, never
# negative. Keeping the constraint here means bad input fails at the API
# boundary with a 422 instead of blowing up as a 500 in the data layer.
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
    status: PetStatus = PetStatus.AVAILABLE
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
    status: PetStatus | None = None
    category_id: int | None = None

class PetOut(PetBase):
    id: int

    model_config = {"from_attributes": True}
