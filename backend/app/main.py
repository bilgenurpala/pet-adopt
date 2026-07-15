from fastapi import FastAPI
from app.core.errors import add_exception_handlers


app = FastAPI(title="Pet Store API", version="1.0.0")

add_exception_handlers(app)

@app.get("/health")
def health():
    return {"status": "ok"}
