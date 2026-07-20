from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.adoption_application import AdoptionApplication
from app.models.enums import ApplicationStatus, PetStatus
from app.models.pet import Pet
from app.models.user import User
from app.services import pet_service

ACTIVE_STATUSES = (ApplicationStatus.PENDING, ApplicationStatus.APPROVED)

PET_STATUS_AFTER = {
    ApplicationStatus.APPROVED: PetStatus.PENDING,
    ApplicationStatus.COMPLETED: PetStatus.ADOPTED,
    ApplicationStatus.REJECTED: PetStatus.AVAILABLE,
}

NOT_FOUND = HTTPException(
    status_code=status.HTTP_404_NOT_FOUND, detail="Adoption application not found."
)


def has_active_application(db: Session, user_id: int, pet_id: int) -> bool:
    existing = (
        db.query(AdoptionApplication)
        .filter(
            AdoptionApplication.user_id == user_id,
            AdoptionApplication.pet_id == pet_id,
            AdoptionApplication.status.in_(ACTIVE_STATUSES),
        )
        .first()
    )
    return existing is not None


def create_application(
    db: Session, applicant: User, pet_id: int, message: str | None
) -> AdoptionApplication:
    pet = pet_service.get_viewable_pet(db, pet_id, applicant)

    if pet.owner_id == applicant.id:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You cannot apply to adopt your own listing.",
        )

    if has_active_application(db, applicant.id, pet.id):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You already have an active application for this pet.",
        )

    application = AdoptionApplication(
        user_id=applicant.id,
        pet_id=pet.id,
        message=message,
        status=ApplicationStatus.PENDING,
    )
    db.add(application)
    db.commit()
    db.refresh(application)
    return application


def get_visible_application(
    db: Session, application_id: int, user: User
) -> AdoptionApplication:
    application = db.get(AdoptionApplication, application_id)
    if application is None:
        raise NOT_FOUND

    if not pet_service.is_admin(user) and application.user_id != user.id:
        raise NOT_FOUND

    return application


def change_status(
    db: Session, application: AdoptionApplication, new_status: ApplicationStatus
) -> AdoptionApplication:
    application.status = new_status

    pet_status = PET_STATUS_AFTER.get(new_status)
    if pet_status is not None:
        pet = db.get(Pet, application.pet_id)
        if pet is not None:
            pet.status = pet_status

    db.commit()
    db.refresh(application)
    return application
