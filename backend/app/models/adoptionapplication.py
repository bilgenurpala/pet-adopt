from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
from .enums import ApplicationStatus


class AdoptionApplication(Base):
    __tablename__ = "adoption_application"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    pet_id = Column(Integer, ForeignKey("pet.id"), nullable=False)

    message = Column(String, nullable=True)  # Applicant's "why I want to adopt" text
    status = Column(Enum(ApplicationStatus, name="application_status_enum"),
                    nullable=False,
                    default=ApplicationStatus.PENDING)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    user = relationship("User")
    pet = relationship("Pet")
