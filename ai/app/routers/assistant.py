from fastapi import APIRouter

from app.schemas.assistant import AssistantRequest, AssistantResponse
from app.services import assistant_service

router = APIRouter(tags=["ai"])


@router.post("/assistant", response_model=AssistantResponse)
def assistant(req: AssistantRequest):
    return assistant_service.run_assistant(req)
