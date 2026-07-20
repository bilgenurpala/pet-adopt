from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.deps import get_current_user, require_admin
from app.core.pagination import PaginationParams, paginate
from app.core.security import hash_password
from app.database import get_db
from app.models.adoption_application import AdoptionApplication
from app.models.enums import Role
from app.models.pet import Pet
from app.models.user import User
from app.schemas.common import Page
from app.schemas.user import UserCreate, UserOut, UserRoleUpdate, UserUpdate

router = APIRouter(prefix="/users", tags=["users"])

NOT_FOUND = HTTPException(
    status_code=status.HTTP_404_NOT_FOUND, detail="User not found."
)


def _get_user(db: Session, user_id: int) -> User:
    user = db.get(User, user_id)
    if user is None:
        raise NOT_FOUND
    return user


def _ensure_identity_is_free(
    db: Session,
    username: str | None,
    email: str | None,
    current_id: int | None = None,
) -> None:
    filters = []
    if username is not None:
        filters.append(User.username == username)
    if email is not None:
        filters.append(User.email == email)
    if not filters:
        return

    query = db.query(User).filter(or_(*filters))
    if current_id is not None:
        query = query.filter(User.id != current_id)

    if query.first() is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this email or username already exists.",
        )


@router.get("/me", response_model=UserOut)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.get("", response_model=Page[UserOut])
def list_users(
    db: Session = Depends(get_db),
    pagination: PaginationParams = Depends(),
    current_user: User = Depends(require_admin),
):
    query = db.query(User)
    total = query.count()
    items = (
        query.order_by(User.id)
        .offset(pagination.offset)
        .limit(pagination.per_page)
        .all()
    )
    return paginate(items, total, pagination)


@router.get("/{user_id}", response_model=UserOut)
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    return _get_user(db, user_id)


@router.post("", response_model=UserOut, status_code=status.HTTP_201_CREATED)
def create_user(
    payload: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    _ensure_identity_is_free(db, payload.username, payload.email)

    user = User(
        username=payload.username,
        email=payload.email,
        full_name=payload.full_name,
        password_hash=hash_password(payload.password),
        role=Role.USER,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.patch("/{user_id}", response_model=UserOut)
def update_user(
    user_id: int,
    payload: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    user = _get_user(db, user_id)

    changes = payload.model_dump(exclude_unset=True)
    _ensure_identity_is_free(
        db, changes.get("username"), changes.get("email"), current_id=user.id
    )

    if "password" in changes:
        user.password_hash = hash_password(changes.pop("password"))

    for field, value in changes.items():
        setattr(user, field, value)

    db.commit()
    db.refresh(user)
    return user


@router.patch("/{user_id}/role", response_model=UserOut)
def change_user_role(
    user_id: int,
    payload: UserRoleUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    user = _get_user(db, user_id)
    user.role = payload.role
    db.commit()
    db.refresh(user)
    return user


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    user = _get_user(db, user_id)

    pet_count = db.query(Pet).filter(Pet.owner_id == user.id).count()
    application_count = (
        db.query(AdoptionApplication)
        .filter(AdoptionApplication.user_id == user.id)
        .count()
    )

    if pet_count or application_count:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                f"This user still has {pet_count} listing(s) and "
                f"{application_count} application(s). Remove them before "
                "deleting the account."
            ),
        )

    db.delete(user)
    db.commit()
