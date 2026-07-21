from fastapi import APIRouter

from app.schemas.recommend import RecommendPetRequest, RecommendPetResponse
from app.services import recommend_service

router = APIRouter(tags=["ai"])


@router.post("/recommend-pet", response_model=RecommendPetResponse)
def recommend_pet(req: RecommendPetRequest):
    return recommend_service.recommend_pet(req)
