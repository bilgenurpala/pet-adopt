import sys
from decimal import Decimal
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.database import Base, get_db
import app.models as _models  # noqa: F401
from app.models.category import Category
from app.models.enums import EnergyLevel, Gender, Role, Size, Species
from app.models.pet import Pet
from app.models.user import User
from app.main import app


@pytest.fixture
def engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    yield engine
    engine.dispose()


@pytest.fixture
def session_factory(engine):
    return sessionmaker(bind=engine, autocommit=False, autoflush=False)


@pytest.fixture
def db(session_factory):
    session = session_factory()
    yield session
    session.close()


@pytest.fixture
def client(session_factory):
    def override_get_db():
        session = session_factory()
        try:
            yield session
        finally:
            session.close()

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def user_payload():
    return {
        "username": "bilge",
        "email": "bilge@example.com",
        "full_name": "Bilgenur Pala",
        "password": "supersecret1",
    }


@pytest.fixture
def registered_user(client, user_payload):
    response = client.post("/auth/register", json=user_payload)
    assert response.status_code == 201
    return response.json()


@pytest.fixture
def login_body(client, registered_user, user_payload):
    response = client.post(
        "/auth/login",
        json={"email": user_payload["email"], "password": user_payload["password"]},
    )
    assert response.status_code == 200
    return response.json()


@pytest.fixture
def user_token(login_body):
    return login_body["access_token"]


@pytest.fixture
def user_refresh_token(login_body):
    return login_body["refresh_token"]


def _register_and_login(client, db, payload, role):
    assert client.post("/auth/register", json=payload).status_code == 201

    user = db.query(User).filter(User.email == payload["email"]).one()
    if user.role != role:
        user.role = role
        db.commit()
    user_id = user.id

    response = client.post(
        "/auth/login",
        json={"email": payload["email"], "password": payload["password"]},
    )
    assert response.status_code == 200
    return user_id, response.json()["access_token"]


@pytest.fixture
def admin(client, db):
    user_id, token = _register_and_login(
        client,
        db,
        {
            "username": "admin",
            "email": "admin@example.com",
            "full_name": "Site Admin",
            "password": "adminsecret1",
        },
        Role.ADMIN,
    )
    return {"id": user_id, "token": token}


@pytest.fixture
def other_user(client, db):
    user_id, token = _register_and_login(
        client,
        db,
        {
            "username": "arjin",
            "email": "arjin@example.com",
            "full_name": "Arjin",
            "password": "othersecret1",
        },
        Role.USER,
    )
    return {"id": user_id, "token": token}


@pytest.fixture
def auth():
    def _auth(token):
        return {"Authorization": f"Bearer {token}"}

    return _auth


@pytest.fixture
def category(db):
    item = Category(name="Dogs")
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@pytest.fixture
def make_pet(db, category):
    def _make_pet(owner_id, **overrides):
        fields = {
            "name": "Karamel",
            "species": Species.DOG,
            "breed": "Golden Retriever",
            "age": Decimal("2.5"),
            "gender": Gender.FEMALE,
            "size": Size.MEDIUM,
            "energy_level": EnergyLevel.HIGH,
            "category_id": category.id,
            "owner_id": owner_id,
            "is_approved": False,
        }
        fields.update(overrides)

        pet = Pet(**fields)
        db.add(pet)
        db.commit()
        db.refresh(pet)
        return pet

    return _make_pet


@pytest.fixture
def pet_payload(category):
    return {
        "name": "Boncuk",
        "species": Species.CAT.value,
        "breed": "Tekir",
        "age": "1.5",
        "gender": Gender.MALE.value,
        "size": Size.SMALL.value,
        "energy_level": EnergyLevel.LOW.value,
        "category_id": category.id,
    }
