from datetime import datetime
from pydantic import BaseModel
from .enums import OrderStatus

class OrderBase(BaseModel):
    user_id: int
    pet_id: int
    quantity: int

class OrderCreate(OrderBase):
    pass

class OrderUpdate(BaseModel):
    status: OrderStatus | None = None

class OrderOut(OrderBase):
    id: int
    status: OrderStatus 
    created_at: datetime

    model_config = {"from_attributes": True}