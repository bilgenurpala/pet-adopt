from pydantic import BaseModel, Field

class ClassifyImageResponse(BaseModel):
    species: str
    breed_guess: str
    confidence: float = Field(ge=0.0, le=1.0)
