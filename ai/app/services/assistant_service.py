from fastapi import HTTPException

from app.core.json_parse import INVALID_OUTPUT, extract_json_object
from app.core.llm_client import ask_claude
from app.data.pet_repository import get_adoptable_pets
from app.prompts import assistant_v1, router_v1
from app.prompts.age_format import format_age
from app.schemas.assistant import AssistantRequest, AssistantResponse, PetCard
from app.services.classify_service import classify_image

ACTION_PRECEDENCE = ("recommend", "answer", "describe", "classify", "chat")
NEEDS_PET_LIST = ("recommend", "chat")


def _conversation_text(messages) -> str:
    lines = []
    for message in messages:
        speaker = "Person" if message.role == "user" else "Assistant"
        text = (message.content or "").strip()
        if message.image is not None:
            text = f"{text} [attached a photo]".strip()
        lines.append(f"{speaker}: {text}")
    return "\n".join(lines)


def _latest_image(messages):
    for message in reversed(messages):
        if message.role == "user":
            return message.image
    return None


def _fallback_plan() -> dict:
    return {"steps": ["chat"], "pet_reference": None, "preferences": ""}


def _plan(conversation: str, has_image: bool) -> dict:
    try:
        raw = ask_claude(
            prompt=router_v1.build_prompt(conversation, has_image),
            system=router_v1.SYSTEM,
            max_tokens=300,
        )
        data = extract_json_object(raw)
    except Exception:
        return _fallback_plan()

    steps = [
        step
        for step in data.get("steps") or []
        if isinstance(step, str) and step in router_v1.MODEL_STEPS
    ]
    if not steps:
        return _fallback_plan()

    reference = data.get("pet_reference")
    if reference is not None and not isinstance(reference, (str, int)):
        reference = None

    return {
        "steps": steps,
        "pet_reference": reference,
        "preferences": str(data.get("preferences") or "").strip(),
    }


def _find_pet(pets: list[dict], reference) -> dict | None:
    if reference is None:
        return None

    text = str(reference).strip().lower()
    if not text:
        return None

    if text.isdigit():
        pet_id = int(text)
        match = next((pet for pet in pets if pet["id"] == pet_id), None)
        if match is not None:
            return match

    return next((pet for pet in pets if pet["name"].strip().lower() == text), None)


def _compose(
    conversation: str,
    classification: dict | None,
    pets: list[dict],
    focus_pet: dict | None,
    preferences: str,
) -> tuple[str, list[int]]:
    raw = ask_claude(
        prompt=assistant_v1.build_prompt(
            conversation, classification, pets, focus_pet, preferences
        ),
        system=assistant_v1.SYSTEM,
        max_tokens=1200,
    )
    data = extract_json_object(raw)

    reply = str(data.get("reply") or "").strip()
    if not reply:
        raise INVALID_OUTPUT

    pet_ids = []
    for value in data.get("pet_ids") or []:
        try:
            pet_ids.append(int(value))
        except (TypeError, ValueError):
            continue

    return reply, pet_ids


def _to_card(pet: dict) -> PetCard:
    return PetCard(
        id=pet["id"],
        name=pet["name"],
        species=pet["species"],
        breed=pet["breed"],
        age=format_age(pet["age"]),
        gender=pet["gender"],
        size=pet["size"],
        energy_level=pet["energy_level"],
        photo_url=pet["photo_url"],
    )


def _resolve_action(steps: list[str], has_image: bool) -> str:
    effective = set(steps)
    if has_image:
        effective.add("classify")

    for action in ACTION_PRECEDENCE:
        if action in effective:
            return action
    return "chat"


def run_assistant(req: AssistantRequest) -> AssistantResponse:
    messages = req.messages
    conversation = _conversation_text(messages)
    image = _latest_image(messages)
    has_image = image is not None

    classification = None
    if has_image:
        classification = classify_image(
            image_base64=image.data, media_type=image.media_type
        ).model_dump()

    plan = _plan(conversation, has_image)
    steps = plan["steps"]

    pets: list[dict] = []
    focus_pet = None

    if any(step in NEEDS_PET_LIST for step in steps) or has_image:
        pets = get_adoptable_pets()

    if plan["pet_reference"] is not None:
        if not pets:
            pets = get_adoptable_pets()
        focus_pet = _find_pet(pets, plan["pet_reference"])

    reply, pet_ids = _compose(
        conversation=conversation,
        classification=classification,
        pets=pets,
        focus_pet=focus_pet,
        preferences=plan["preferences"],
    )

    known = {pet["id"]: pet for pet in pets}
    if focus_pet is not None:
        known[focus_pet["id"]] = focus_pet

    cards = []
    seen = set()
    for pet_id in pet_ids:
        pet = known.get(pet_id)
        if pet is None or pet_id in seen:
            continue
        seen.add(pet_id)
        cards.append(_to_card(pet))

    return AssistantResponse(
        reply=reply,
        pets=cards,
        action=_resolve_action(steps, has_image),
    )
