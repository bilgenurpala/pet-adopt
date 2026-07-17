from datetime import datetime
from pydantic import BaseModel
from .enums import ApplicationStatus

class AdoptionApplicationBase(BaseModel):
    user_id: int
    pet_id: int
    message: str | None = None  

class AdoptionApplicationCreate(AdoptionApplicationBase):
    pass  
class AdoptionApplicationUpdate(BaseModel):
    status: ApplicationStatus | None = None  

class AdoptionApplicationOut(AdoptionApplicationBase):
    id: int
    status: ApplicationStatus
    created_at: datetime

    model_config = {"from_attributes": True}