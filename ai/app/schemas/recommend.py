from pydantic import BaseModel

class RecommendPetRequest(BaseModel):
    preferences: str

class RecommendPetResponse(BaseModel):
    pet_id: int
    name: str
    reason: str
    photo_url: str
