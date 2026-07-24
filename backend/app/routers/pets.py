from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.core.deps import get_current_user, get_current_user_optional, require_admin
from app.core.pagination import PaginationParams, paginate
from app.database import get_db
from app.models.adoption_application import AdoptionApplication
from app.models.category import Category
from app.models.enums import EnergyLevel, PetStatus, Role, Size, Species
from app.models.favorite import Favorite
from app.models.pet import Pet
from app.models.user import User
from app.schemas.common import Page
from app.schemas.pet import PetCreate, PetOut, PetUpdate
from app.services import pet_service
from app.services.upload_service import UploadError, save_upload

router = APIRouter(prefix="/pets", tags=["pets"])


def _ensure_category_exists(db: Session, category_id: int) -> None:
    if db.get(Category, category_id) is None:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=f"Category {category_id} does not exist.",
        )


@router.get("", response_model=Page[PetOut])
def list_pets(
    db: Session = Depends(get_db),
    pagination: PaginationParams = Depends(),
    species: Species | None = None,
    size: Size | None = None,
    energy_level: EnergyLevel | None = None,
    pet_status: PetStatus | None = Query(None, alias="status"),
):
    query = pet_service.publicly_visible_pets(db)

    if species is not None:
        query = query.filter(Pet.species == species)
    if size is not None:
        query = query.filter(Pet.size == size)
    if energy_level is not None:
        query = query.filter(Pet.energy_level == energy_level)
    if pet_status is not None:
        query = query.filter(Pet.status == pet_status)

    total = query.count()
    items = (
        query.order_by(Pet.id)
        .offset(pagination.offset)
        .limit(pagination.per_page)
        .all()
    )
    return paginate(items, total, pagination)


@router.get("/mine", response_model=Page[PetOut])
def list_my_pets(
    db: Session = Depends(get_db),
    pagination: PaginationParams = Depends(),
    current_user: User = Depends(get_current_user),
):
    query = db.query(Pet).filter(Pet.owner_id == current_user.id)

    total = query.count()
    items = (
        query.order_by(Pet.id)
        .offset(pagination.offset)
        .limit(pagination.per_page)
        .all()
    )
    return paginate(items, total, pagination)


@router.get("/pending", response_model=Page[PetOut])
def list_pending_pets(
    db: Session = Depends(get_db),
    pagination: PaginationParams = Depends(),
    current_user: User = Depends(require_admin),
):
    query = db.query(Pet).filter(Pet.is_approved.is_(False))

    total = query.count()
    items = (
        query.order_by(Pet.id)
        .offset(pagination.offset)
        .limit(pagination.per_page)
        .all()
    )
    return paginate(items, total, pagination)


@router.get("/{pet_id}", response_model=PetOut)
def get_pet(
    pet_id: int,
    db: Session = Depends(get_db),
    current_user: User | None = Depends(get_current_user_optional),
):
    return pet_service.get_viewable_pet(db, pet_id, current_user)


@router.post("", response_model=PetOut, status_code=status.HTTP_201_CREATED)
def create_pet(
    payload: PetCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _ensure_category_exists(db, payload.category_id)

    pet = Pet(
        **payload.model_dump(),
        owner_id=current_user.id,
        is_approved=pet_service.is_admin(current_user),
    )
    db.add(pet)
    db.commit()
    db.refresh(pet)
    return pet


@router.patch("/{pet_id}", response_model=PetOut)
def update_pet(
    pet_id: int,
    payload: PetUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pet = pet_service.get_manageable_pet(db, pet_id, current_user)

    changes = payload.model_dump(exclude_unset=True)
    if "category_id" in changes:
        _ensure_category_exists(db, changes["category_id"])

    for field, value in changes.items():
        setattr(pet, field, value)

    db.commit()
    db.refresh(pet)
    return pet


@router.delete("/{pet_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_pet(
    pet_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pet = pet_service.get_manageable_pet(db, pet_id, current_user)

    application_count = (
        db.query(AdoptionApplication)
        .filter(AdoptionApplication.pet_id == pet.id)
        .count()
    )
    favorite_count = db.query(Favorite).filter(Favorite.pet_id == pet.id).count()

    if application_count or favorite_count:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                f"This pet still has {application_count} application(s) and "
                f"{favorite_count} favorite(s). Remove them before deleting "
                "the listing."
            ),
        )

    db.delete(pet)
    db.commit()


@router.patch("/{pet_id}/approve", response_model=PetOut)
def approve_pet(
    pet_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    pet = db.get(Pet, pet_id)
    if pet is None:
        raise pet_service.NOT_FOUND

    pet.is_approved = True
    db.commit()
    db.refresh(pet)
    return pet


@router.post("/{pet_id}/photo", response_model=PetOut)
async def upload_pet_photo(
    pet_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pet = pet_service.get_manageable_pet(db, pet_id, current_user)
    content = await file.read()

    try:
        pet.photo_url = save_upload(file.filename or "", content)
    except UploadError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT, detail=str(exc)
        )

    db.commit()
    db.refresh(pet)
    return pet
