from typing import Literal

from pydantic import BaseModel, Field

MediaType = Literal["image/jpeg", "image/png", "image/webp", "image/gif"]
Action = Literal["recommend", "answer", "describe", "classify", "chat"]


class MessageImage(BaseModel):
    media_type: MediaType
    data: str = Field(min_length=1)


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
