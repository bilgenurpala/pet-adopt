import unittest
from decimal import Decimal
from uuid import uuid4

from .database_test_base import DatabaseTestCase
from app.models.adoption_application import AdoptionApplication
from app.models.category import Category
from app.models.enums import (
    ApplicationStatus,
    EnergyLevel,
    Gender,
    PetStatus,
    Role,
    Size,
    Species,
)
from app.models.favorite import Favorite
from app.models.pet import Pet
from app.core.security import hash_password
from app.models.user import User


class TestDatabaseRelationships(DatabaseTestCase):
    def create_user(self, prefix: str) -> User:
        suffix = uuid4().hex[:8]

        user = User(
            username=f"{prefix}_{suffix}",
            email=f"{prefix}_{suffix}@example.com",
            full_name=f"{prefix.title()} User",
            role=Role.USER,
            password_hash=hash_password("secret123"),
        )

        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)

        return user

    def create_category(self, prefix: str) -> Category:
        suffix = uuid4().hex[:8]

        category = Category(name=f"{prefix} {suffix}")

        self.db.add(category)
        self.db.commit()
        self.db.refresh(category)

        return category

    def create_pet(self, owner: User, category: Category, prefix: str) -> Pet:
        suffix = uuid4().hex[:8]

        pet = Pet(
            name=f"{prefix} {suffix}",
            species=Species.CAT,
            breed="Mixed Breed",
            age=2,
            gender=Gender.FEMALE,
            size=Size.MEDIUM,
            energy_level=EnergyLevel.MEDIUM,
            description="Relationship test pet.",
            photo_url=None,
            adoption_fee=Decimal("75.00"),
            status=PetStatus.AVAILABLE,
            owner_id=owner.id,
            category_id=category.id,
            is_approved=True,
        )

        self.db.add(pet)
        self.db.commit()
        self.db.refresh(pet)

        return pet

    def test_user_pet_relationship_works(self):
        owner = self.create_user("relationship_owner")
        category = self.create_category("Relationship Category")
        pet = self.create_pet(owner, category, "Relationship Pet")

        self.db.refresh(owner)

        self.assertEqual(pet.owner.id, owner.id)
        self.assertEqual(pet.owner.username, owner.username)
        self.assertEqual(len(owner.pets), 1)
        self.assertEqual(owner.pets[0].id, pet.id)

        self.db.delete(pet)
        self.db.delete(category)
        self.db.delete(owner)
        self.db.commit()

    def test_category_pet_relationship_works(self):
        owner = self.create_user("category_owner")
        category = self.create_category("Category Relationship")
        pet = self.create_pet(owner, category, "Category Pet")

        self.db.refresh(category)

        self.assertEqual(pet.category.id, category.id)
        self.assertEqual(pet.category.name, category.name)
        self.assertEqual(len(category.pets), 1)
        self.assertEqual(category.pets[0].id, pet.id)

        self.db.delete(pet)
        self.db.delete(category)
        self.db.delete(owner)
        self.db.commit()

    def test_adoption_application_relationships_work(self):
        owner = self.create_user("application_owner")
        applicant = self.create_user("application_applicant")
        category = self.create_category("Application Relationship")
        pet = self.create_pet(owner, category, "Application Relationship Pet")

        application = AdoptionApplication(
            user_id=applicant.id,
            pet_id=pet.id,
            message="Relationship test application.",
            status=ApplicationStatus.PENDING,
        )

        self.db.add(application)
        self.db.commit()
        self.db.refresh(application)

        self.assertEqual(application.user.id, applicant.id)
        self.assertEqual(application.user.username, applicant.username)
        self.assertEqual(application.pet.id, pet.id)
        self.assertEqual(application.pet.name, pet.name)

        self.db.delete(application)
        self.db.delete(pet)
        self.db.delete(category)
        self.db.delete(applicant)
        self.db.delete(owner)
        self.db.commit()

    def test_favorite_relationships_work(self):
        owner = self.create_user("favorite_owner")
        user = self.create_user("favorite_user")
        category = self.create_category("Favorite Relationship")
        pet = self.create_pet(owner, category, "Favorite Relationship Pet")

        favorite = Favorite(
            user_id=user.id,
            pet_id=pet.id,
        )

        self.db.add(favorite)
        self.db.commit()

        saved_favorite = self.db.query(Favorite).filter(
            Favorite.user_id == user.id,
            Favorite.pet_id == pet.id,
        ).one()

        self.assertEqual(saved_favorite.user.id, user.id)
        self.assertEqual(saved_favorite.user.username, user.username)
        self.assertEqual(saved_favorite.pet.id, pet.id)
        self.assertEqual(saved_favorite.pet.name, pet.name)

        self.db.delete(saved_favorite)
        self.db.delete(pet)
        self.db.delete(category)
        self.db.delete(user)
        self.db.delete(owner)
        self.db.commit()


if __name__ == "__main__":
    unittest.main(verbosity=2)