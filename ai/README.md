# PetAdopt AI Service

The independent PetAdopt AI API: a FastAPI service powered by Anthropic Claude
for listing descriptions, lifestyle-based recommendations, image
classification, and a conversational assistant.

[![FastAPI](https://img.shields.io/badge/FastAPI-API-009688?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Claude](https://img.shields.io/badge/Anthropic-Claude-D97757)](https://www.anthropic.com/claude)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)

## Architecture

```mermaid
flowchart LR
    Client["Flutter client"] --> Assistant["POST /assistant"]
    Assistant --> Router["Intent router"]
    Router --> Description["Description flow"]
    Router --> Recommend["Recommendation flow"]
    Router --> Classify["Image classification flow"]
    Description --> Claude["Anthropic Claude"]
    Classify --> Claude
    Recommend --> Claude
    Recommend --> DB[("PostgreSQL read-only")]
```

The AI service can be deployed, restarted, or rate-limited independently from
the main backend. It reads eligible pets directly from PostgreSQL for
recommendations but does not modify application data.

## Tech stack

| Area | Choice |
|---|---|
| API | FastAPI, Pydantic v2 |
| LLM provider | Anthropic Claude |
| Reliability | Tenacity retries for transient failures |
| Pet catalogue | Read-only SQLAlchemy queries |
| Prompts | Versioned Python modules |
| Image input | Multipart uploads and base64 assistant content |
| Tests | pytest with mocked LLM calls |

## Getting started

Python 3.12 is recommended. Run the following commands from this directory.

```bash
python -m venv .venv
```

Activate the environment and install the dependencies:

```bash
# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt
```

Create `ai/.env`:

```env
ANTHROPIC_API_KEY=your-api-key
DATABASE_URL=postgresql+psycopg2://petadopt:petadopt@localhost:5432/petadopt
LLM_MAX_ATTEMPTS=3
LLM_WAIT_MIN=1
LLM_WAIT_MAX=10
CORS_ORIGINS=http://localhost:3000,http://localhost:8000
```

The recommendation endpoint needs a migrated and seeded PetAdopt database.
Prepare it from the repository root:

```bash
docker compose up -d db
cd backend
python -m alembic upgrade head
python seed.py
cd ../ai
```

Start the service:

```bash
python -m uvicorn app.main:app --reload --port 8001
```

- API: http://localhost:8001
- Swagger UI: http://localhost:8001/docs
- Health check: http://localhost:8001/health

## AI endpoints

| Endpoint | Input | Purpose |
|---|---|---|
| `POST /generate-description` | Pet attributes | Writes an adoption listing |
| `POST /recommend-pet` | Free-text lifestyle description | Returns the best matching real pet |
| `POST /classify-image` | Pet image | Identifies species and estimates breed |
| `POST /assistant` | Message history and optional image | Routes the conversation to the correct capability |

`/assistant` is stateless. The client sends the complete message history on
every request. Recommendation results always reference a real, approved,
available listing and its stored `photo_url`; the service does not generate
pet images.

## Request flow

```mermaid
sequenceDiagram
    participant C as Client
    participant A as Assistant API
    participant R as Intent router
    participant S as AI service flow
    participant L as Claude

    C->>A: messages + optional image
    A->>R: classify intent
    R-->>A: description / recommend / classify
    A->>S: validated input
    S->>L: versioned prompt
    L-->>S: model response
    S-->>A: parsed and validated output
    A-->>C: typed JSON response
```

## Prompt design

Prompts live in `app/prompts/` as feature-specific, versioned modules:

- `description_v1.py`
- `recommend_v1.py`
- `classify_v1.py`
- `assistant_v1.py`
- `router_v1.py`

Each module exports `PROMPT_VERSION`, allowing a response to be traced to the
prompt that produced it. Formatting rules that must be deterministic, such as
age and adoption fee display, are implemented in code before the prompt is
built.

## Reliability and validation

- Only rate limits, provider 5xx responses, and network failures are retried.
- Invalid requests and authentication failures are not retried.
- Retry count and wait bounds are configurable through environment variables.
- Provider failures are logged and returned to the client as `502`.
- LLM output is parsed and validated before it reaches the API response.
- Recommendations filter out unapproved, pending, and adopted pets.

## Testing

The suite mocks every Anthropic call, so it does not consume API credits. Dummy
configuration values are sufficient:

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

The suite covers existing endpoints, assistant routing, image input, output
validation, and deterministic fee formatting.

## Docker

Run the complete stack from the repository root:

```bash
docker compose up --build
```

Docker Compose publishes the AI service at http://localhost:8001 and starts it
only after the migration and seed job completes successfully.

## Project structure

```text
app/
├── core/       Configuration, JSON parsing, and the LLM client
├── data/       Read-only pet repository
├── prompts/    Versioned prompts and deterministic formatters
├── routers/    FastAPI endpoints
├── schemas/    Typed request and response contracts
└── services/   Description, recommendation, classification, assistant flows
tests/          Mocked AI unit and integration tests
```
