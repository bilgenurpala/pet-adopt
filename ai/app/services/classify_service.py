from pydantic import ValidationError

from app.core.json_parse import INVALID_OUTPUT, extract_json_object
from app.core.llm_client import ask_claude_vision
from app.prompts import classify_v1
from app.schemas.classify import ClassifyImageResponse

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "image/gif"}
MAX_SIZE = 5 * 1024 * 1024


def classify_image(image_base64: str, media_type: str) -> ClassifyImageResponse:
    raw = ask_claude_vision(
        prompt=classify_v1.build_prompt(),
        image_base64=image_base64,
        media_type=media_type,
        system=classify_v1.SYSTEM,
    )
    data = extract_json_object(raw)

    try:
        return ClassifyImageResponse(**data)
    except ValidationError:
        raise INVALID_OUTPUT
