import logging

from anthropic import APIError
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.routers import assistant, classify, description, recommend

logger = logging.getLogger("petadopt.ai")

app = FastAPI(title="PetAdopt AI Service", version="2.1.0")


@app.exception_handler(APIError)
def handle_provider_error(request: Request, exc: APIError):
    logger.exception("Anthropic API call failed on %s", request.url.path)
    return JSONResponse(
        status_code=502,
        content={"detail": f"The AI provider rejected the request: {type(exc).__name__}"},
    )

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(description.router)
app.include_router(recommend.router)
app.include_router(classify.router)
app.include_router(assistant.router)


@app.get("/health")
def health():
    return {"status": "ok"}
