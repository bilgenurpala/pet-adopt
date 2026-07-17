from pydantic import BaseModel

class GenerateDescriptionRequest(BaseModel):
    name: str
    species: str
    breed: str
    age: int
    gender: str
    size: str
    energy_level: str

class GenerateDescriptionResponse(BaseModel):
    title: str
    description: str