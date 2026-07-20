import uuid
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2]
UPLOAD_DIR = BASE_DIR / "uploads"
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
MAX_SIZE = 5 * 1024 * 1024

class UploadError(Exception):
    pass

def save_upload(filename: str, content: bytes) -> str:
    ext = Path(filename).suffix.lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise UploadError(f"Unsupported file type: {ext or 'none'}")
    if len(content) > MAX_SIZE:
        raise UploadError("File too large (max 5MB)")

    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    unique_name = f"{uuid.uuid4().hex}{ext}"
    target = UPLOAD_DIR / unique_name
    target.write_bytes(content)
    return f"/uploads/{unique_name}"
