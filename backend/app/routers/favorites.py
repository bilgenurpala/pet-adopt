from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_current_user
from app.core.pagination import PaginationParams, paginate
from app.database import get_db
from app.models.favorite import Favorite
from app.models.pet import Pet
from app.models.user import User
from app.schemas.common import Page
from app.schemas.favorite import FavoriteCreate
from app.schemas.pet import PetOut

router = APIRouter(prefix="/favorites", tags=["favorites"])

PET_NOT_FOUND = HTTPException(
    status_code=status.HTTP_404_NOT_FOUND, detail="Pet not found."
)

FAVORITE_NOT_FOUND = HTTPException(
    status_code=status.HTTP_404_NOT_FOUND, detail="Favorite not found."
)

ALREADY_FAVORITED = HTTPException(
    status_code=status.HTTP_409_CONFLICT, detail="Pet is already in your favorites."
)


@router.post("", response_model=PetOut, status_code=status.HTTP_201_CREATED)
def add_favorite(
    payload: FavoriteCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pet = db.get(Pet, payload.pet_id)
    if pet is None:
        raise PET_NOT_FOUND

    if db.get(Favorite, (current_user.id, pet.id)) is not None:
        raise ALREADY_FAVORITED

    db.add(Favorite(user_id=current_user.id, pet_id=pet.id))
    db.commit()
    db.refresh(pet)
    return pet


@router.delete("/{pet_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_favorite(
    pet_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    favorite = db.get(Favorite, (current_user.id, pet_id))
    if favorite is None:
        raise FAVORITE_NOT_FOUND

    db.delete(favorite)
    db.commit()


@router.get("", response_model=Page[PetOut])
def list_favorites(
    db: Session = Depends(get_db),
    pagination: PaginationParams = Depends(),
    current_user: User = Depends(get_current_user),
):
    query = (
        db.query(Pet)
        .join(Favorite, Favorite.pet_id == Pet.id)
        .filter(Favorite.user_id == current_user.id)
    )

    total = query.count()
    items = (
        query.order_by(Pet.id)
        .offset(pagination.offset)
        .limit(pagination.per_page)
        .all()
    )
    return paginate(items, total, pagination)
