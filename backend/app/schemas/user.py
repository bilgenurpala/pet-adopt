from pydantic import BaseModel, EmailStr, Field
from .enums import Role

class UserBase(BaseModel):
    username: str
    email: EmailStr
    full_name: str

class UserCreate(UserBase):
    password: str = Field(min_length=8, max_length=72)

class UserUpdate(BaseModel):
    username: str | None = None
    email: EmailStr | None = None
    full_name: str | None = None
    password: str | None = Field(default=None, min_length=8, max_length=72)

class UserOut(UserBase):
    id: int
    role: Role

    model_config = {"from_attributes": True}