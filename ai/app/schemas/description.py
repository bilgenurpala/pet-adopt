from decimal import Decimal
from typing import Annotated

from pydantic import BaseModel, Field

# Same constraint as the backend Pet schema, so the two services agree on
# what a valid age looks like.
PetAge = Annotated[Decimal, Field(max_digits=3, decimal_places=1, ge=0)]

class GenerateDescriptionRequest(BaseModel):
    name: str
    species: str
    breed: str
    age: PetAge
    gender: str
    size: str
    energy_level: str

class GenerateDescriptionResponse(BaseModel):
    title: str
    description: str