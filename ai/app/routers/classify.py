import base64

from fastapi import APIRouter, File, HTTPException, UploadFile

from app.schemas.classify import ClassifyImageResponse
from app.services import classify_service

router = APIRouter(tags=["ai"])


@router.post("/classify-image", response_model=ClassifyImageResponse)
async def classify_image(file: UploadFile = File(...)):
    if file.content_type not in classify_service.ALLOWED_TYPES:
        raise HTTPException(status_code=415, detail="Unsupported image type")

    content = await file.read()
    if len(content) > classify_service.MAX_SIZE:
        raise HTTPException(status_code=413, detail="Image too large (max 5MB)")

    return classify_service.classify_image(
        image_base64=base64.b64encode(content).decode(),
        media_type=file.content_type,
    )
