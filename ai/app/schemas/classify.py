from typing import Literal

from pydantic import BaseModel, Field


class ClassifyImageResponse(BaseModel):
    species: Literal["cat", "dog", "bird", "fish", "other"]
    breed_guess: str
    confidence: float = Field(ge=0.0, le=1.0)
