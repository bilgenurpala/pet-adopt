from datetime import datetime

from pydantic import BaseModel, model_validator

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


class AdminApplicationOut(AdoptionApplicationOut):
    applicant_name: str = ""
    applicant_email: str = ""
    pet_name: str = ""
    pet_photo_url: str | None = None

    @model_validator(mode="before")
    @classmethod
    def flatten_relations(cls, data):
        if hasattr(data, "user") and data.user is not None:
            data.applicant_name = data.user.full_name
            data.applicant_email = data.user.email
        if hasattr(data, "pet") and data.pet is not None:
            data.pet_name = data.pet.name
            data.pet_photo_url = data.pet.photo_url
        return data

