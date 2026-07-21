from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.routers import assistant, classify, description, recommend

app = FastAPI(title="PetAdopt AI Service", version="2.1.0")

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
