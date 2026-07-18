from fastapi import FastAPI

from app.routers import classify, description, recommend

app = FastAPI(title="PetAdopt AI Service", version="2.0.0")

app.include_router(description.router)
app.include_router(recommend.router)
app.include_router(classify.router)

@app.get("/health")
def health():
    return {"status": "ok"}