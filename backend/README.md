# PetAdopt Backend

PetAdopt'un kimlik doğrulama, ilan, kategori, favori, sahiplendirme ve yönetim
işlemlerini sağlayan FastAPI servisidir.

## Teknolojiler

- FastAPI ve Pydantic v2
- SQLAlchemy 2 ve PostgreSQL 16
- Alembic migrations
- JWT access/refresh token
- pytest

## Yerel kurulum

Python 3.12 önerilir. Komutları bu klasörün içinden çalıştırın:

```bash
python -m venv .venv
```

Sanal ortamı etkinleştirin:

```bash
# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# macOS / Linux
source .venv/bin/activate
```

Bağımlılıkları yükleyin:

```bash
pip install -r requirements.txt
```

`backend/.env` dosyasını oluşturun:

```env
DATABASE_URL=postgresql+psycopg2://petadopt:petadopt@localhost:5432/petadopt
SECRET_KEY=replace-with-a-long-random-secret
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7
```

Proje kökünde yalnızca PostgreSQL'i başlatabilirsiniz:

```bash
docker compose up -d db
```

Veritabanını hazırlayıp örnek verileri ekleyin:

```bash
python -m alembic upgrade head
python seed.py
```

Servisi başlatın:

```bash
python -m uvicorn app.main:app --reload --port 8000
```

- API: http://localhost:8000
- Swagger UI: http://localhost:8000/docs
- Health check: http://localhost:8000/health

## API grupları

| Grup | Yol | Açıklama |
|---|---|---|
| Auth | `/auth` | Kayıt, giriş ve token yenileme |
| Pets | `/pets` | İlan listeleme, oluşturma, düzenleme, onaylama ve fotoğraf yükleme |
| Categories | `/categories` | Kategori listeleme ve yönetimi |
| Favorites | `/favorites` | Kullanıcının favori ilanları |
| Adoptions | `/adoptions` | Sahiplendirme başvuruları ve durum yönetimi |
| Users | `/users` | Profil ve admin kullanıcı yönetimi |
| Admin | `/admin/stats` | Yönetim paneli istatistikleri |

Endpointlerin güncel istek ve yanıt şemaları için Swagger UI'ı kullanın.
Korumalı endpointlerde `Authorization: Bearer <access-token>` başlığı gerekir.

## Testler

Testler izole bir SQLite veritabanı kullanır; çalışan PostgreSQL gerekmez:

```bash
pytest -q
```

Belirli bir test dosyasını çalıştırmak için:

```bash
pytest tests/test_auth.py -q
```

## Migration oluşturma

Model değişikliklerinden sonra:

```bash
python -m alembic revision --autogenerate -m "describe change"
python -m alembic upgrade head
```

Oluşturulan migration dosyasını commit etmeden önce mutlaka inceleyin.

## Docker

Backend'i veritabanı, migration ve AI servisiyle birlikte çalıştırmak için proje
kökünde:

```bash
docker compose up --build
```

Seed işlemi tabloları temizleyip bilinen örnek veri setini yeniden oluşturur;
mevcut yerel verilerin üzerine yazabileceği için geliştirme veritabanlarında
dikkatli kullanılmalıdır.
