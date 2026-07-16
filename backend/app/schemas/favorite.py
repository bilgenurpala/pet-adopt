from pydantic import BaseModel

class FavoriteBase(BaseModel):
    user_id: int
    pet_id: int

class FavoriteCreate(FavoriteBase):
    pass

class FavoriteOut(FavoriteBase):
    model_config = {"from_attributes": True}