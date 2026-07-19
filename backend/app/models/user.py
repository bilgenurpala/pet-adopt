from sqlalchemy import Column, Integer, String, Enum
from sqlalchemy.orm import relationship
from app.database import Base
from .enums import Role


class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=False)
    password_hash = Column(String(128), nullable=False)
    role = Column(
        Enum(Role, values_callable=lambda e: [i.value for i in e]),
        nullable=False,
        default=Role.USER,
        server_default=Role.USER.value,
    )

    pets = relationship("Pet", back_populates="owner")
