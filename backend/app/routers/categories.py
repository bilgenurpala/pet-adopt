from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import require_admin
from app.core.pagination import PaginationParams, paginate
from app.database import get_db
from app.models.category import Category
from app.models.pet import Pet
from app.models.user import User
from app.schemas.category import CategoryCreate, CategoryOut, CategoryUpdate
from app.schemas.common import Page

router = APIRouter(prefix="/categories", tags=["categories"])

NOT_FOUND = HTTPException(
    status_code=status.HTTP_404_NOT_FOUND, detail="Category not found."
)


def _get_category(db: Session, category_id: int) -> Category:
    category = db.get(Category, category_id)
    if category is None:
        raise NOT_FOUND
    return category


def _ensure_name_is_free(db: Session, name: str, current_id: int | None = None) -> None:
    query = db.query(Category).filter(Category.name == name)
    if current_id is not None:
        query = query.filter(Category.id != current_id)

    if query.first() is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"A category named '{name}' already exists.",
        )


@router.get("", response_model=Page[CategoryOut])
def list_categories(
    db: Session = Depends(get_db),
    pagination: PaginationParams = Depends(),
):
    query = db.query(Category)
    total = query.count()
    items = (
        query.order_by(Category.id)
        .offset(pagination.offset)
        .limit(pagination.per_page)
        .all()
    )
    return paginate(items, total, pagination)


@router.get("/{category_id}", response_model=CategoryOut)
def get_category(category_id: int, db: Session = Depends(get_db)):
    return _get_category(db, category_id)


@router.post("", response_model=CategoryOut, status_code=status.HTTP_201_CREATED)
def create_category(
    payload: CategoryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    _ensure_name_is_free(db, payload.name)

    category = Category(name=payload.name)
    db.add(category)
    db.commit()
    db.refresh(category)
    return category


@router.patch("/{category_id}", response_model=CategoryOut)
def update_category(
    category_id: int,
    payload: CategoryUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    category = _get_category(db, category_id)

    changes = payload.model_dump(exclude_unset=True)
    if "name" in changes:
        _ensure_name_is_free(db, changes["name"], current_id=category.id)

    for field, value in changes.items():
        setattr(category, field, value)

    db.commit()
    db.refresh(category)
    return category


@router.delete("/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_category(
    category_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    category = _get_category(db, category_id)

    pet_count = db.query(Pet).filter(Pet.category_id == category.id).count()
    if pet_count:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                f"This category still has {pet_count} listing(s). "
                "Move or remove them before deleting it."
            ),
        )

    db.delete(category)
    db.commit()
