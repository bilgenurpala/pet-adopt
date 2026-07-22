from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.core.errors import add_exception_handlers
from app.routers import admin, adoptions, auth, categories, favorites, pets, users
from app.services.upload_service import UPLOAD_DIR

app = FastAPI(title=settings.app_name, version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

add_exception_handlers(app)

UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

app.include_router(admin.router)
app.include_router(auth.router)
app.include_router(pets.router)
app.include_router(adoptions.router)
app.include_router(categories.router)
app.include_router(favorites.router)
app.include_router(users.router)


@app.get("/health")
def health():
    return {"status": "ok"}