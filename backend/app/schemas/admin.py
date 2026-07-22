from pydantic import BaseModel


class AdminStatsOut(BaseModel):
    total_users: int
    total_pets: int
    pending_pets: int
    total_applications: int
    pending_applications: int
