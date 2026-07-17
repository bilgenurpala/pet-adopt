from fastapi import FastAPI
from app.core.config import settings
from app.core.errors import add_exception_handlers

app = FastAPI(title=settings.app_name, version="2.0.0")

add_exception_handlers(app)

@app.get("/health")
def health():
    return {"status": "ok"}
