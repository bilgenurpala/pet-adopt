# PetAdopt

VBT Internship 2026 project. A pet adoption platform built as a modern take
on the Swagger Petstore API: a FastAPI backend, a separate Claude-powered AI
service, and a Flutter client.

The original Petstore domain was a shop. We pivoted it to adoption, which
changed the meaning of most of the model: `price` became an optional
`adoption_fee`, orders became adoption applications, and users can post
their own listings for an admin to approve.

## Repository layout

```
backend/     Pet adoption API (FastAPI + PostgreSQL)
ai/          AI service (FastAPI + Claude)
frontend/    Flutter client (web and mobile from one codebase)
docker-compose.yml
```

The two Python services are deliberately separate: the AI service can be
restarted, rate-limited or taken down without affecting the main API.

## Tech stack

| Area | Choice |
|---|---|
| API | FastAPI, Pydantic v2 |
| Database | PostgreSQL 16, SQLAlchemy 2, Alembic |
| Auth | bcrypt password hashing, role-based access (`user` / `admin`) |
| AI | Anthropic Claude, versioned prompt modules, tenacity retries |
| Client | Flutter, Dio, Riverpod-style providers, go_router |
| Errors | RFC 7807 Problem Details (`application/problem+json`) |

## Getting started

### 1. Database

Requires Docker Desktop. From the repository root:

```bash
docker compose up -d
docker compose ps
```

Wait until `petadopt-db` reports `healthy`. Data lives in a named volume,
so it survives `docker compose down` and you only need to seed once.

### 2. Backend

Create `backend/.env`:

```
DATABASE_URL=postgresql+psycopg2://petadopt:petadopt@localhost:5432/petadopt
```

Then:

```bash
cd backend
pip install -r requirements.txt
python -m alembic upgrade head
python seed.py
python -m uvicorn app.main:app --reload --port 8000
```

`seed.py` clears the tables before inserting, so it is safe to re-run.

Run the tests with `python -m pytest tests/ -q`. They use in-memory SQLite
and do not require the database to be running.

### 3. AI service

Create `ai/.env`:

```
ANTHROPIC_API_KEY=your-key-here
DATABASE_URL=postgresql+psycopg2://petadopt:petadopt@localhost:5432/petadopt
```

Then:

```bash
cd ai
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8001
```

Interactive docs at http://localhost:8001/docs.

### 4. Flutter client

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

## AI service endpoints

| Endpoint | Purpose |
|---|---|
| `POST /generate-description` | Writes an adoption listing from a pet's attributes |
| `POST /recommend-pet` | Picks the best match for a free-text description of the adopter's lifestyle |
| `POST /classify-image` | Identifies species and guesses breed from a photo |

`/recommend-pet` reads pets directly from the database and only considers
listings that are `available` **and** approved, so unapproved user listings
never surface in recommendations.

Prompts live in `ai/app/prompts/` as versioned modules (`description_v1`,
`recommend_v1`, `classify_v1`). Each exports a `PROMPT_VERSION`, so a
response can always be traced back to the prompt that produced it.

Ages below one year are rendered as "approximately N months" before the
prompt is built. This is done in code rather than left to the model,
because "0.5 years old" reads badly and models tend to echo it back.

## Data model

Five tables: `pet`, `category`, `user`, `adoption_application`, `favorites`.

The field list is frozen in the data contract issue and is the single
source of truth. Models, Pydantic schemas and Flutter types all follow it,
and **any change to it must be discussed in that issue before
implementation** — the three layers break independently otherwise.

Details worth knowing without reading the contract:

- `pet.age` is `decimal(3,1)`, not an integer, so young animals can be
  represented (`0.5` = about six months).
- `pet.owner_id` and `pet.is_approved` support user-submitted listings.
  A listing from a regular user starts unapproved and is invisible to the
  public until an admin approves it.
- Defaults for `role`, `status` and `is_approved` are database defaults, so
  a raw SQL insert succeeds without supplying them.
- `favorites` uses a composite primary key, so the same user cannot
  favourite the same pet twice.
- Password hashing lives in the service layer (`app/core/security.py`).
  Models store `password_hash` and nothing more.

## Seed data

`backend/seed.py` builds a realistic dataset: 35 pets across all five
species with varied size and energy levels, 5 categories, 1 admin and 2
regular users, adoption applications covering all four statuses, and a few
favourites. A handful of pets are `adopted` or `pending`, and a few are
unapproved user listings, so every filter and permission path has something
to exercise.

## Project status

**Done**

- Data layer: models, migrations, seed, 14 database tests
- Backend core: config, bcrypt security helpers, Problem Details handlers,
  pagination, local file upload service
- Pydantic schemas for all five resources
- AI service: all three endpoints, reading live data
- Flutter client: pet list, detail, favourites, profile and AI chat screens,
  networking and routing layers

**In progress**

- Backend routers — only `/health` exists so far; CRUD, auth and the
  approval flow are the next milestone
- RAG over listing text
- Dockerfiles for the two services and CI

## Conventions

- Work happens on a branch per issue, named `feature/issue-NN-slug` or
  `fix/issue-NN-slug`. Nothing is committed directly to `main`.
- Pull requests reference their issue with `Closes #NN`.
- Commit messages follow Conventional Commits (`feat:`, `fix:`,
  `refactor:`, `chore:`).
- `.env` files are gitignored and must never be committed. The credentials
  in this README are for local development only.

## Team

| Area | Owner |
|---|---|
| Data layer — models, migrations, seed | Seda |
| Service layer, AI service | Bilge |
| Flutter client | Arjin, Seda |
