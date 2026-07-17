import json

from fastapi import APIRouter, HTTPException
from pydantic import ValidationError

from app.core.llm_client import ask_claude
from app.prompts import description_v1
from app.schemas.description import GenerateDescriptionRequest, GenerateDescriptionResponse

router = APIRouter(tags=["ai"])

@router.post("/generate-description", response_model=GenerateDescriptionResponse)
def generate_description(req: GenerateDescriptionRequest):
    raw = ask_claude(prompt=description_v1.build_prompt(req), system=description_v1.SYSTEM)

    start = raw.find("{")
    end = raw.rfind("}")
    if start == -1 or end == -1:
        raise HTTPException(status_code=502, detail="AI returned invalid output")

    try:
        data = json.loads(raw[start:end + 1])
        return GenerateDescriptionResponse(**data)
    except (json.JSONDecodeError, ValidationError):
        raise HTTPException(status_code=502, detail="AI returned invalid output")