import base64
import binascii
import re
from typing import Literal

from pydantic import BaseModel, Field, field_validator

MediaType = Literal["image/jpeg", "image/png", "image/webp", "image/gif"]
Action = Literal["recommend", "answer", "describe", "classify", "chat"]

DATA_URL_PREFIX = re.compile(r"^data:[^;,]*;base64,", re.IGNORECASE)
MAX_IMAGE_BYTES = 5 * 1024 * 1024


class MessageImage(BaseModel):
    media_type: MediaType
    data: str = Field(min_length=1)

    @field_validator("data")
    @classmethod
    def clean_and_check(cls, value: str) -> str:
        value = DATA_URL_PREFIX.sub("", "".join(value.split()))
        if not value:
            raise ValueError("image data is empty")

        try:
            decoded = base64.b64decode(value, validate=True)
        except (binascii.Error, ValueError):
            raise ValueError("image data is not valid base64")

        if len(decoded) > MAX_IMAGE_BYTES:
            raise ValueError("image is larger than 5MB")

        return value


class Message(BaseModel):
    role: Literal["user", "assistant"]
    content: str = ""
    image: MessageImage | None = None


class AssistantRequest(BaseModel):
    messages: list[Message] = Field(min_length=1)


class PetCard(BaseModel):
    id: int
    name: str
    species: str
    breed: str
    age: str
    gender: str
    size: str
    energy_level: str
    photo_url: str | None = None


class AssistantResponse(BaseModel):
    reply: str
    pets: list[PetCard] = []
    action: Action
