from pydantic import ValidationError

from app.core.json_parse import INVALID_OUTPUT, extract_json_object
from app.core.llm_client import ask_claude
from app.prompts import description_v1
from app.schemas.description import (
    GenerateDescriptionRequest,
    GenerateDescriptionResponse,
)


def generate_description(
    req: GenerateDescriptionRequest,
) -> GenerateDescriptionResponse:
    raw = ask_claude(
        prompt=description_v1.build_prompt(req),
        system=description_v1.SYSTEM,
    )
    data = extract_json_object(raw)

    try:
        return GenerateDescriptionResponse(**data)
    except ValidationError:
        raise INVALID_OUTPUT
