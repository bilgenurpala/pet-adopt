from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session, joinedload

from app.core.deps import get_current_user, require_admin
from app.core.pagination import PaginationParams, paginate
from app.database import get_db
from app.models.adoption_application import AdoptionApplication
from app.models.enums import ApplicationStatus
from app.models.user import User
from app.schemas.adoption import (
    AdminApplicationOut,
    AdoptionApplicationCreate,
    AdoptionApplicationOut,
    AdoptionApplicationStatusUpdate,
)
from app.schemas.common import Page
from app.services import adoption_service, pet_service

router = APIRouter(prefix="/adoptions", tags=["adoptions"])


@router.post(
    "", response_model=AdoptionApplicationOut, status_code=status.HTTP_201_CREATED
)
def create_application(
    payload: AdoptionApplicationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return adoption_service.create_application(
        db, current_user, payload.pet_id, payload.message
    )


@router.get("")
def list_applications(
    db: Session = Depends(get_db),
    pagination: PaginationParams = Depends(),
    current_user: User = Depends(get_current_user),
    application_status: ApplicationStatus | None = Query(None, alias="status"),
):
    is_admin_user = pet_service.is_admin(current_user)
    query = db.query(AdoptionApplication)

    if is_admin_user:
        query = query.options(
            joinedload(AdoptionApplication.user),
            joinedload(AdoptionApplication.pet),
        )
    else:
        query = query.filter(AdoptionApplication.user_id == current_user.id)

    if application_status is not None:
        query = query.filter(AdoptionApplication.status == application_status)

    total = query.count()
    items = (
        query.order_by(AdoptionApplication.id)
        .offset(pagination.offset)
        .limit(pagination.per_page)
        .all()
    )

    schema = AdminApplicationOut if is_admin_user else AdoptionApplicationOut
    serialized = [schema.model_validate(item) for item in items]
    return paginate(serialized, total, pagination)


@router.get("/{application_id}", response_model=AdoptionApplicationOut)
def get_application(
    application_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return adoption_service.get_visible_application(db, application_id, current_user)


@router.patch("/{application_id}/status", response_model=AdoptionApplicationOut)
def change_application_status(
    application_id: int,
    payload: AdoptionApplicationStatusUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    application = adoption_service.get_visible_application(
        db, application_id, current_user
    )
    return adoption_service.change_status(db, application, payload.status)
