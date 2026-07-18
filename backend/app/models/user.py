from sqlalchemy import Column, Integer, String, Enum
from sqlalchemy.orm import relationship
from app.database import Base
from app.core.security import hash_password, verify_password
from .enums import Role


class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=True)
    password_hash = Column(String(128), nullable=False)  # Never store plain passwords — hashed in service layer
    role = Column(Enum(Role, name="role_enum"), nullable=False, default=Role.USER)

    pets = relationship(
        "Pet",
        back_populates="owner"
    )

    def set_password(self, password: str) -> None:
        self.password_hash = hash_password(password)

    def check_password(self, password: str) -> bool:
        if not self.password_hash:
            return False
        return verify_password(password, self.password_hash)
