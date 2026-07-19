import unittest
from decimal import Decimal
from uuid import uuid4

from .database_test_base import DatabaseTestCase
from app.models.adoptionapplication import AdoptionApplication
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
from app.models.favorites import Favorite
from app.models.pet import Pet
from app.models.user import User


class TestDatabaseTables(DatabaseTestCase):
    def create_user(self, prefix: str = "user") -> User:
        suffix = uuid4().hex[:8]

        user = User(
            username=f"{prefix}_{suffix}",
            email=f"{prefix}_{suffix}@example.com",
            full_name=f"{prefix.title()} Test User",
            role=Role.USER,
        )
        user.set_password("secret123")

        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)

        return user

    def create_category(self, prefix: str = "Category") -> Category:
        suffix = uuid4().hex[:8]

        category = Category(name=f"{prefix} {suffix}")

        self.db.add(category)
        self.db.commit()
        self.db.refresh(category)

        return category

    def create_pet(self, owner: User, category: Category, prefix: str = "Pet") -> Pet:
        suffix = uuid4().hex[:8]

        pet = Pet(
            name=f"{prefix} {suffix}",
            species=Species.DOG,
            breed="Golden Retriever",
            age=3,
            gender=Gender.MALE,
            size=Size.LARGE,
            energy_level=EnergyLevel.HIGH,
            description="A friendly database test pet.",
            photo_url="https://example.com/test-pet.jpg",
            adoption_fee=Decimal("100.00"),
            status=PetStatus.AVAILABLE,
            owner_id=owner.id,
            category_id=category.id,
            is_approved=True,
        )

        self.db.add(pet)
        self.db.commit()
        self.db.refresh(pet)

        return pet

    def test_user_table_insert_read_delete(self):
        user = self.create_user("table_user")

        saved_user = self.db.query(User).filter(User.id == user.id).one()

        self.assertEqual(saved_user.id, user.id)
        self.assertEqual(saved_user.username, user.username)
        self.assertEqual(saved_user.email, user.email)
        self.assertEqual(saved_user.role, Role.USER)
        self.assertTrue(saved_user.check_password("secret123"))

        self.db.delete(saved_user)
        self.db.commit()

        deleted_user = self.db.query(User).filter(User.id == user.id).first()
        self.assertIsNone(deleted_user)

    def test_category_table_insert_read_delete(self):
        category = self.create_category("Table Category")

        saved_category = self.db.query(Category).filter(Category.id == category.id).one()

        self.assertEqual(saved_category.id, category.id)
        self.assertEqual(saved_category.name, category.name)

        self.db.delete(saved_category)
        self.db.commit()

        deleted_category = self.db.query(Category).filter(Category.id == category.id).first()
        self.assertIsNone(deleted_category)

    def test_pet_table_insert_read_delete(self):
        owner = self.create_user("pet_owner")
        category = self.create_category("Pet Category")
        pet = self.create_pet(owner, category, "Table Pet")

        saved_pet = self.db.query(Pet).filter(Pet.id == pet.id).one()

        self.assertEqual(saved_pet.id, pet.id)
        self.assertEqual(saved_pet.owner_id, owner.id)
        self.assertEqual(saved_pet.category_id, category.id)
        self.assertEqual(saved_pet.species, Species.DOG)
        self.assertEqual(saved_pet.gender, Gender.MALE)
        self.assertEqual(saved_pet.size, Size.LARGE)
        self.assertEqual(saved_pet.energy_level, EnergyLevel.HIGH)
        self.assertEqual(saved_pet.status, PetStatus.AVAILABLE)
        self.assertTrue(saved_pet.is_approved)

        self.db.delete(saved_pet)
        self.db.delete(category)
        self.db.delete(owner)
        self.db.commit()

    def test_adoption_application_table_insert_read_delete(self):
        owner = self.create_user("application_owner")
        applicant = self.create_user("application_user")
        category = self.create_category("Application Category")
        pet = self.create_pet(owner, category, "Application Pet")

        application = AdoptionApplication(
            user_id=applicant.id,
            pet_id=pet.id,
            message="I would like to adopt this pet.",
            status=ApplicationStatus.PENDING,
        )

        self.db.add(application)
        self.db.commit()
        self.db.refresh(application)

        saved_application = self.db.query(AdoptionApplication).filter(
            AdoptionApplication.id == application.id
        ).one()

        self.assertEqual(saved_application.user_id, applicant.id)
        self.assertEqual(saved_application.pet_id, pet.id)
        self.assertEqual(saved_application.status, ApplicationStatus.PENDING)
        self.assertEqual(saved_application.message, "I would like to adopt this pet.")
        self.assertIsNotNone(saved_application.created_at)

        self.db.delete(saved_application)
        self.db.delete(pet)
        self.db.delete(category)
        self.db.delete(applicant)
        self.db.delete(owner)
        self.db.commit()

    def test_favorites_table_insert_read_delete(self):
        owner = self.create_user("favorite_owner")
        user = self.create_user("favorite_user")
        category = self.create_category("Favorite Category")
        pet = self.create_pet(owner, category, "Favorite Pet")

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

        self.assertEqual(saved_favorite.user_id, user.id)
        self.assertEqual(saved_favorite.pet_id, pet.id)

        self.db.delete(saved_favorite)
        self.db.delete(pet)
        self.db.delete(category)
        self.db.delete(user)
        self.db.delete(owner)
        self.db.commit()


if __name__ == "__main__":
    unittest.main(verbosity=2)