import json

from fastapi import APIRouter, HTTPException
from pydantic import ValidationError

from app.core.llm_client import ask_claude
from app.data.mock_pets import get_adoptable_pets
from app.prompts import recommend_v1
from app.schemas.recommend import RecommendPetRequest, RecommendPetResponse

router = APIRouter(tags=["ai"])

@router.post("/recommend-pet", response_model=RecommendPetResponse)
def recommend_pet(req: RecommendPetRequest):
    pets = get_adoptable_pets()
    if not pets:
        raise HTTPException(status_code=404, detail="No adoptable pets available")

    raw = ask_claude(
        prompt=recommend_v1.build_prompt(req.preferences, pets),
        system=recommend_v1.SYSTEM,
    )

    start = raw.find("{")
    end = raw.rfind("}")
    if start == -1 or end == -1:
        raise HTTPException(status_code=502, detail="AI returned invalid output")

    try:
        data = json.loads(raw[start:end + 1])
        pet_id = int(data["pet_id"])
        reason = str(data["reason"])
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        raise HTTPException(status_code=502, detail="AI returned invalid output")

    pet = next((p for p in pets if p["id"] == pet_id), None)
    if pet is None:
        raise HTTPException(status_code=502, detail="AI recommended an unavailable pet")

    try:
        return RecommendPetResponse(
            pet_id=pet["id"],
            name=pet["name"],
            reason=reason,
            photo_url=pet["photo_url"],
        )
    except ValidationError:
        raise HTTPException(status_code=502, detail="AI returned invalid output")
