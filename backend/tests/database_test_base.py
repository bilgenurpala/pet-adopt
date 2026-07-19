import sys
import os
import unittest
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

# .env dosyasını testlerin de bulabilmesi için yolu belirliyoruz
from dotenv import load_dotenv
env_path = ROOT / ".env"
load_dotenv(dotenv_path=env_path)

from app.database import Base
# İşte tabloların veritabanında oluşması için gereken gizli kahraman:
import app.models as _models  # noqa: F401

# Bellek üzerinde çalışan, süper hızlı geçici SQLite veritabanı
TEST_DATABASE_URL = "sqlite:///:memory:"
test_engine = create_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

class DatabaseTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Modeller import edildiği için create_all tüm tabloları RAM'de oluşturur
        Base.metadata.create_all(bind=test_engine)

    def setUp(self):
        # Her test için yeni bir session
        self.db = TestingSessionLocal()

    def tearDown(self):
        # Test bittiğinde değişiklikleri geri al ve kapat
        self.db.rollback()
        self.db.close()