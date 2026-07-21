from sqlalchemy import create_engine, text

from app.core.config import settings

_engine = None

ADOPTABLE_PETS_SQL = text(
    """
    SELECT id,
           name,
           species,
           breed,
           age,
           gender,
           size,
           energy_level,
           adoption_fee,
           COALESCE(description, '') AS description,
           photo_url
    FROM "pet"
    WHERE status = 'available'
      AND is_approved = true
    ORDER BY id
    """
)


def get_engine():
    global _engine
    if _engine is None:
        _engine = create_engine(settings.database_url, pool_pre_ping=True)
    return _engine


def get_adoptable_pets() -> list[dict]:
    with get_engine().connect() as connection:
        rows = connection.execute(ADOPTABLE_PETS_SQL).mappings().all()
    return [dict(row) for row in rows]
