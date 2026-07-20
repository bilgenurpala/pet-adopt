from datetime import datetime

from pydantic import BaseModel

from .enums import ApplicationStatus


class AdoptionApplicationCreate(BaseModel):
    pet_id: int
    message: str | None = None


class AdoptionApplicationStatusUpdate(BaseModel):
    status: ApplicationStatus


class AdoptionApplicationOut(BaseModel):
    id: int
    user_id: int
    pet_id: int
    message: str | None = None
    status: ApplicationStatus
    created_at: datetime

    model_config = {"from_attributes": True}
