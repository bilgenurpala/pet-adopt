from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import require_admin
from app.database import get_db
from app.models.adoption_application import AdoptionApplication
from app.models.enums import ApplicationStatus
from app.models.pet import Pet
from app.models.user import User
from app.schemas.admin import AdminStatsOut

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/stats", response_model=AdminStatsOut)
def get_stats(
    db: Session = Depends(get_db),
    _: User = Depends(require_admin),
):
    return AdminStatsOut(
        total_users=db.query(User).count(),
        total_pets=db.query(Pet).count(),
        pending_pets=db.query(Pet).filter(Pet.is_approved.is_(False)).count(),
        total_applications=db.query(AdoptionApplication).count(),
        pending_applications=db.query(AdoptionApplication)
        .filter(AdoptionApplication.status == ApplicationStatus.PENDING)
        .count(),
    )
