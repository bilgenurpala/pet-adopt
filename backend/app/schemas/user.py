from pydantic import BaseModel, EmailStr
from .enums import Role

class UserBase(BaseModel):
    username: str
    email: EmailStr
    full_name: str

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    username: str | None = None
    email: EmailStr | None = None
    full_name: str | None = None
    password: str | None = None

class UserOut(UserBase):
    id: int
    role: Role

    model_config = {"from_attributes": True}