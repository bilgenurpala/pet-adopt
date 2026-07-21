from fastapi import APIRouter

from app.schemas.description import (
    GenerateDescriptionRequest,
    GenerateDescriptionResponse,
)
from app.services import description_service

router = APIRouter(tags=["ai"])


@router.post("/generate-description", response_model=GenerateDescriptionResponse)
def generate_description(req: GenerateDescriptionRequest):
    return description_service.generate_description(req)
