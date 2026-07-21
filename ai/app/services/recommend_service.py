from fastapi import HTTPException
from pydantic import ValidationError

from app.core.json_parse import INVALID_OUTPUT, extract_json_object
from app.core.llm_client import ask_claude
from app.data.pet_repository import get_adoptable_pets
from app.prompts import recommend_v1
from app.schemas.recommend import RecommendPetRequest, RecommendPetResponse

NO_PETS = HTTPException(status_code=404, detail="No adoptable pets available")
UNAVAILABLE_PET = HTTPException(
    status_code=502, detail="AI recommended an unavailable pet"
)


def recommend_pet(req: RecommendPetRequest) -> RecommendPetResponse:
    pets = get_adoptable_pets()
    if not pets:
        raise NO_PETS

    raw = ask_claude(
        prompt=recommend_v1.build_prompt(req.preferences, pets),
        system=recommend_v1.SYSTEM,
    )
    data = extract_json_object(raw)

    try:
        pet_id = int(data["pet_id"])
        reason = str(data["reason"])
    except (KeyError, TypeError, ValueError):
        raise INVALID_OUTPUT

    pet = next((p for p in pets if p["id"] == pet_id), None)
    if pet is None:
        raise UNAVAILABLE_PET

    try:
        return RecommendPetResponse(
            pet_id=pet["id"],
            name=pet["name"],
            reason=reason,
            photo_url=pet["photo_url"],
        )
    except ValidationError:
        raise INVALID_OUTPUT
