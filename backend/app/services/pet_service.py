from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.enums import Role
from app.models.pet import Pet
from app.models.user import User

NOT_FOUND = HTTPException(
    status_code=status.HTTP_404_NOT_FOUND, detail="Pet not found."
)


def is_owner(pet: Pet, user: User) -> bool:
    return pet.owner_id == user.id


def is_admin(user: User) -> bool:
    return user.role == Role.ADMIN


def can_view(pet: Pet, user: User | None) -> bool:
    if pet.is_approved:
        return True
    if user is None:
        return False
    return is_admin(user) or is_owner(pet, user)


def can_manage(pet: Pet, user: User) -> bool:
    return is_admin(user) or is_owner(pet, user)


def get_viewable_pet(db: Session, pet_id: int, user: User | None) -> Pet:
    pet = db.get(Pet, pet_id)
    if pet is None or not can_view(pet, user):
        raise NOT_FOUND
    return pet


def get_manageable_pet(db: Session, pet_id: int, user: User) -> Pet:
    pet = db.get(Pet, pet_id)
    if pet is None or not can_view(pet, user):
        raise NOT_FOUND
    if not can_manage(pet, user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only modify your own listings.",
        )
    return pet
