import uuid
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt

from app.core.config import settings

ACCESS_TOKEN_TYPE = "access"
REFRESH_TOKEN_TYPE = "refresh"


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())


def _create_token(user_id: int, token_type: str, lifetime: timedelta) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),
        "type": token_type,
        "jti": uuid.uuid4().hex,
        "iat": now,
        "exp": now + lifetime,
    }
    return jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)


def create_access_token(user_id: int) -> str:
    return _create_token(
        user_id,
        ACCESS_TOKEN_TYPE,
        timedelta(minutes=settings.access_token_expire_minutes),
    )


def create_refresh_token(user_id: int) -> str:
    return _create_token(
        user_id,
        REFRESH_TOKEN_TYPE,
        timedelta(days=settings.refresh_token_expire_days),
    )


def _decode_token(token: str, expected_type: str) -> int | None:
    try:
        payload = jwt.decode(
            token, settings.secret_key, algorithms=[settings.algorithm]
        )
    except jwt.InvalidTokenError:
        return None

    if payload.get("type") != expected_type:
        return None

    sub = payload.get("sub")
    if sub is None:
        return None

    try:
        return int(sub)
    except ValueError:
        return None


def decode_access_token(token: str) -> int | None:
    return _decode_token(token, ACCESS_TOKEN_TYPE)


def decode_refresh_token(token: str) -> int | None:
    return _decode_token(token, REFRESH_TOKEN_TYPE)
