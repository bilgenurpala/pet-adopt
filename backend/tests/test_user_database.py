import unittest
from uuid import uuid4
from sqlalchemy import inspect as sa_inspect

from database_test_base import DatabaseTestCase, test_engine # app.database engine yerine test_engine'i al
from app.models.user import User
from app.core.security import hash_password, verify_password

class TestDatabaseConnection(DatabaseTestCase):
    def test_database_connection_works(self):
        # engine yerine test_engine kullan
        with test_engine.connect() as connection:
            self.assertIsNotNone(connection)

class TestDatabaseSchema(DatabaseTestCase):
    def test_required_tables_exist(self):
        # engine yerine test_engine kullan
        inspector = sa_inspect(test_engine)
        tables = set(inspector.get_table_names())

        self.assertIn("user", tables)
        self.assertIn("category", tables)
        self.assertIn("pet", tables)
        self.assertIn("adoption_application", tables)
        self.assertIn("favorites", tables)

class TestUserPasswordHelpers(DatabaseTestCase):
    def test_hash_password_returns_hash(self):
        hashed = hash_password("secret123")

        self.assertNotEqual(hashed, "secret123")
        self.assertIsInstance(hashed, str)
        self.assertGreater(len(hashed), 0)
        self.assertTrue(verify_password("secret123", hashed))
        self.assertFalse(verify_password("wrong-password", hashed))

    def test_user_model_password_methods_work(self):
        user = User(
            username=f"test_user_{uuid4().hex[:8]}",
            email=f"test_{uuid4().hex[:8]}@example.com",
            full_name="Test User",
        )

        user.set_password("secret123")

        self.assertIsNotNone(user.password_hash)
        self.assertNotEqual(user.password_hash, "secret123")
        self.assertTrue(user.check_password("secret123"))
        self.assertFalse(user.check_password("wrong-password"))

    def test_user_can_be_saved_and_password_checked_after_reload(self):
        username = f"db_user_{uuid4().hex[:8]}"
        email = f"{uuid4().hex[:8]}@example.com"

        user = User(
            username=username,
            email=email,
            full_name="Database User",
        )
        user.set_password("secret123")

        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)

        saved_user = self.db.query(User).filter(User.username == username).one()

        self.assertEqual(saved_user.username, username)
        self.assertEqual(saved_user.email, email)
        self.assertTrue(saved_user.check_password("secret123"))
        self.assertFalse(saved_user.check_password("wrong-password"))

        self.db.delete(saved_user)
        self.db.commit()


if __name__ == "__main__":
    unittest.main(verbosity=2)