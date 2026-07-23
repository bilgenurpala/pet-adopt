# PetAdopt AI Service

PetAdopt'un ilan açıklaması üretme, evcil hayvan önerme, fotoğraf sınıflandırma
ve sohbet asistanı özelliklerini sağlayan bağımsız FastAPI servisidir.

## Teknolojiler

- FastAPI ve Pydantic v2
- Anthropic Python SDK
- Tenacity ile kontrollü retry
- SQLAlchemy ile salt okunur pet sorguları
- pytest ve mock LLM testleri

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

`ai/.env` dosyasını oluşturun:

```env
ANTHROPIC_API_KEY=your-api-key
DATABASE_URL=postgresql+psycopg2://petadopt:petadopt@localhost:5432/petadopt
LLM_MAX_ATTEMPTS=3
LLM_WAIT_MIN=1
LLM_WAIT_MAX=10
CORS_ORIGINS=http://localhost:3000,http://localhost:8000
```

Öneri özelliğinin gerçek ilanları okuyabilmesi için veritabanını proje kökünden
hazırlayın:

```bash
docker compose up -d db
cd backend
python -m alembic upgrade head
python seed.py
cd ../ai
```

Servisi başlatın:

```bash
python -m uvicorn app.main:app --reload --port 8001
```

- API: http://localhost:8001
- Swagger UI: http://localhost:8001/docs
- Health check: http://localhost:8001/health

## Endpointler

| Metot ve yol | Açıklama |
|---|---|
| `POST /generate-description` | Pet özelliklerinden sahiplendirme ilanı metni üretir |
| `POST /recommend-pet` | Kullanıcının yaşam tarzına uygun, veritabanındaki gerçek bir peti önerir |
| `POST /classify-image` | Yüklenen fotoğraftan tür ve olası cins bilgisi çıkarır |
| `POST /assistant` | Mesajın niyetini belirleyip uygun AI akışına yönlendirir |

İstek ve yanıt örnekleri için çalışan serviste Swagger UI'ı açın. `/assistant`
durum tutmaz; istemci her istekte konuşma geçmişinin tamamını gönderir.

## Prompt yapısı

Promptlar `app/prompts/` altında özellik bazında ve sürümlü modüller halinde
tutulur. Her prompt modülü izlenebilirlik için bir `PROMPT_VERSION` dışa
aktarır. Prompt davranışı değiştirildiğinde ilgili testler de güncellenmelidir.

## Hata ve retry davranışı

AI istemcisi yalnızca geçici hataları (rate limit, sunucu ve ağ hataları)
üstel bekleme ile yeniden dener. Geçersiz istek veya kimlik doğrulama gibi
kalıcı 4xx hataları tekrar gönderilmez. Sağlayıcı hataları API'den `502`
olarak döner.

## Testler

Testler Anthropic çağrılarını mock'lar; gerçek API isteği yapılmaz. Ayarların
yüklenebilmesi için sahte ortam değerleri kullanılabilir:

```bash
# Windows PowerShell
$env:ANTHROPIC_API_KEY="test-key"
$env:DATABASE_URL="postgresql+psycopg2://test:test@localhost:5432/test"
pytest -q
```

```bash
# macOS / Linux
ANTHROPIC_API_KEY=test-key \
DATABASE_URL=postgresql+psycopg2://test:test@localhost:5432/test \
pytest -q
```

## Docker

Tüm servisleri birlikte çalıştırmak için proje kökünde:

```bash
docker compose up --build
```

Docker Compose, AI servisini http://localhost:8001 adresinde yayınlar ve
servisi migration/seed işlemi başarıyla tamamlandıktan sonra başlatır.
