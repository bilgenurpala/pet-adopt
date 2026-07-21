from pydantic import BaseModel


class FavoriteCreate(BaseModel):
    pet_id: int
