from fastapi import FastAPI

from app.routers import description

app = FastAPI(title="PetAdopt AI Service", version="2.0.0")

app.include_router(description.router)

@app.get("/health")
def health():
    return {"status": "ok"}