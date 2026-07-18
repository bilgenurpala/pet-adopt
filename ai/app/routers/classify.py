import base64
import json

from fastapi import APIRouter, File, HTTPException, UploadFile
from pydantic import ValidationError

from app.core.llm_client import ask_claude_vision
from app.prompts import classify_v1
from app.schemas.classify import ClassifyImageResponse

router = APIRouter(tags=["ai"])

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "image/gif"}
MAX_SIZE = 5 * 1024 * 1024

@router.post("/classify-image", response_model=ClassifyImageResponse)
async def classify_image(file: UploadFile = File(...)):
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(status_code=415, detail="Unsupported image type")

    content = await file.read()
    if len(content) > MAX_SIZE:
        raise HTTPException(status_code=413, detail="Image too large (max 5MB)")

    raw = ask_claude_vision(
        prompt=classify_v1.build_prompt(),
        image_base64=base64.b64encode(content).decode(),
        media_type=file.content_type,
        system=classify_v1.SYSTEM,
    )

    start = raw.find("{")
    end = raw.rfind("}")
    if start == -1 or end == -1:
        raise HTTPException(status_code=502, detail="AI returned invalid output")

    try:
        data = json.loads(raw[start:end + 1])
        return ClassifyImageResponse(**data)
    except (json.JSONDecodeError, ValidationError):
        raise HTTPException(status_code=502, detail="AI returned invalid output")
