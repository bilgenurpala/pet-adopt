from decimal import Decimal

from app.models.adoption_application import AdoptionApplication
from app.models.enums import (
    ApplicationStatus,
    EnergyLevel,
    Gender,
    Size,
    Species,
)
from app.models.pet import Pet


def _stats_url():
    return "/admin/stats"


def _adoptions_url():
    return "/adoptions"


class TestAdminStats:
    def test_returns_correct_counts(self, client, db, admin, other_user, auth, category):
        pet = Pet(
            name="Rex",
            species=Species.DOG,
            breed="Labrador",
            age=Decimal("3.0"),
            gender=Gender.MALE,
            size=Size.LARGE,
            energy_level=EnergyLevel.HIGH,
            category_id=category.id,
            owner_id=admin["id"],
            is_approved=True,
        )
        unapproved_pet = Pet(
            name="Mimi",
            species=Species.CAT,
            breed="Tekir",
            age=Decimal("1.0"),
            gender=Gender.FEMALE,
            size=Size.SMALL,
            energy_level=EnergyLevel.LOW,
            category_id=category.id,
            owner_id=admin["id"],
            is_approved=False,
        )
        db.add_all([pet, unapproved_pet])
        db.commit()
        db.refresh(pet)

        app1 = AdoptionApplication(
            user_id=other_user["id"],
            pet_id=pet.id,
            status=ApplicationStatus.PENDING,
        )
        app2 = AdoptionApplication(
            user_id=other_user["id"],
            pet_id=pet.id,
            status=ApplicationStatus.APPROVED,
        )
        db.add_all([app1, app2])
        db.commit()

        resp = client.get(_stats_url(), headers=auth(admin["token"]))
        assert resp.status_code == 200

        data = resp.json()
        assert data["total_users"] == 2
        assert data["total_pets"] == 2
        assert data["pending_pets"] == 1
        assert data["total_applications"] == 2
        assert data["pending_applications"] == 1

    def test_forbidden_for_normal_user(self, client, other_user, auth):
        resp = client.get(_stats_url(), headers=auth(other_user["token"]))
        assert resp.status_code == 403

    def test_unauthorized_without_token(self, client):
        resp = client.get(_stats_url())
        assert resp.status_code == 401


class TestAdminApplicationList:
    def _setup_application(self, db, admin, other_user, category):
        pet = Pet(
            name="Buddy",
            species=Species.DOG,
            breed="Beagle",
            age=Decimal("2.0"),
            gender=Gender.MALE,
            size=Size.MEDIUM,
            energy_level=EnergyLevel.MEDIUM,
            category_id=category.id,
            owner_id=admin["id"],
            is_approved=True,
            photo_url="/uploads/pets/buddy.png",
        )
        db.add(pet)
        db.commit()
        db.refresh(pet)

        application = AdoptionApplication(
            user_id=other_user["id"],
            pet_id=pet.id,
            message="I want to adopt Buddy",
            status=ApplicationStatus.PENDING,
        )
        db.add(application)
        db.commit()
        db.refresh(application)
        return pet, application

    def test_admin_sees_enriched_fields(self, client, db, admin, other_user, auth, category):
        pet, _ = self._setup_application(db, admin, other_user, category)

        resp = client.get(_adoptions_url(), headers=auth(admin["token"]))
        assert resp.status_code == 200

        items = resp.json()["items"]
        assert len(items) == 1

        item = items[0]
        assert item["applicant_name"] == "Arjin"
        assert item["applicant_email"] == "arjin@example.com"
        assert item["pet_name"] == "Buddy"
        assert item["pet_photo_url"] == "/uploads/pets/buddy.png"

    def test_normal_user_sees_basic_fields(self, client, db, admin, other_user, auth, category):
        self._setup_application(db, admin, other_user, category)

        resp = client.get(_adoptions_url(), headers=auth(other_user["token"]))
        assert resp.status_code == 200

        items = resp.json()["items"]
        assert len(items) == 1

        item = items[0]
        assert "applicant_name" not in item
        assert "pet_name" not in item
        assert "user_id" in item
        assert "pet_id" in item
