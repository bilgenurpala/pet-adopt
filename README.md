<div align="center">

# 🐾 PetAdopt

### AI-powered pet adoption across web, mobile, and desktop

PetAdopt turns the classic Swagger Petstore into a complete adoption platform
with real listings, role-based workflows, admin moderation and AI-assisted pet
matching.

[![CI](https://img.shields.io/github/actions/workflow/status/bilgenurpala/pet-adopt/ci.yml?branch=main&style=for-the-badge&label=CI)](https://github.com/bilgenurpala/pet-adopt/actions/workflows/ci.yml)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL_16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Claude](https://img.shields.io/badge/Claude_AI-D97757?style=for-the-badge)

[Features](#-features) · [Product Tour](#-product-tour) · [Architecture](#-architecture) · [Component Guides](#-component-guides) · [Quick Start](#-quick-start) · [API](#-api-and-permissions) · [Demo](#-demo-video) · [Testing](#-testing-and-quality) · [Design Decisions](#-technology-choices-and-rationale) · [Project Board](https://github.com/users/bilgenurpala/projects/8/views/1)

</div>

---

## ✨ Features

| Experience | Capabilities |
|---|---|
| **Adopters** | Register and sign in, browse approved pets, search and filter, manage favourites and track adoption applications |
| **Administrators** | Create and manage pet listings, review pending listings, manage application status, control user roles and monitor platform statistics |
| **AI assistant** | Generate listing descriptions, recommend real adoptable pets, classify pet images and answer conversational requests |
| **Platform** | JWT authentication, RFC 7807 errors, pagination, OpenAPI 3.1, Docker Compose, seeded data and automated QA |

### Why this is more than a Petstore clone

The original Petstore shop model was redesigned around adoption. Prices became
optional adoption fees, orders became adoption applications, and user-created
listings now pass through an admin approval workflow. AI recommendations use
real, approved and available pets from PostgreSQL rather than fabricated data.

## 🖼️ Product Tour

### Adopter experience

<table>
  <tr>
    <td width="50%" align="center"><strong>Browse pets</strong></td>
    <td width="50%" align="center"><strong>Search and filter</strong></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/home-page.jpeg" alt="PetAdopt home page with pet cards, species filters, and favourite buttons"></td>
    <td><img src="docs/screenshots/search-and-filtering.jpeg" alt="PetAdopt search results filtered for a pet named Shila"></td>
  </tr>
  <tr>
    <td width="50%" align="center"><strong>Favourites</strong></td>
    <td width="50%" align="center"><strong>My activity</strong></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/favorites.jpeg" alt="Saved favourite pet listing in PetAdopt"></td>
    <td><img src="docs/screenshots/my-activity.jpeg" alt="My Activity page showing an approved adoption application"></td>
  </tr>
  <tr>
    <td width="50%" align="center"><strong>Profile</strong></td>
    <td width="50%" align="center"><strong>Registration</strong></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/profile.jpeg" alt="PetAdopt user profile with favourites, activity, support, and sign-out options"></td>
    <td><img src="docs/screenshots/authentication.jpeg" alt="PetAdopt account registration form"></td>
  </tr>
</table>

### AI assistant

<p align="center">
  <img src="docs/screenshots/ai-assistant.jpeg" alt="PetAdopt AI Assistant recommending suitable real pets for an apartment lifestyle" width="900">
</p>

The assistant interprets lifestyle requests and recommends real, approved, and
available pets from the platform rather than generating fictional listings.

### Mobile experience

These screens were captured from the Flutter application running in an Android
emulator, demonstrating the real mobile layout rather than a browser resize.

<table>
  <tr>
    <td width="50%" align="center"><strong>Sign in</strong></td>
    <td width="50%" align="center"><strong>Registration</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/mobile-login.png" alt="PetAdopt mobile sign-in screen" width="300"></td>
    <td align="center"><img src="docs/screenshots/mobile-registration.png" alt="PetAdopt mobile registration screen" width="300"></td>
  </tr>
  <tr>
    <td width="50%" align="center"><strong>Browse pets</strong></td>
    <td width="50%" align="center"><strong>Favourites</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/mobile-home.png" alt="PetAdopt mobile home screen with filters, pet cards, and bottom navigation" width="300"></td>
    <td align="center"><img src="docs/screenshots/mobile-favorites.png" alt="PetAdopt mobile favourites screen" width="300"></td>
  </tr>
  <tr>
    <td width="50%" align="center"><strong>Profile</strong></td>
    <td width="50%" align="center"><strong>Contact and support</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/mobile-profile.png" alt="PetAdopt mobile profile screen" width="300"></td>
    <td align="center"><img src="docs/screenshots/mobile-contact.png" alt="PetAdopt mobile contact and support screen" width="300"></td>
  </tr>
  <tr>
    <td width="50%" align="center"><strong>AI assistant</strong></td>
    <td width="50%" align="center"><strong>AI recommendation</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/mobile-ai-assistant.png" alt="PetAdopt mobile AI Assistant conversation screen" width="300"></td>
    <td align="center"><img src="docs/screenshots/mobile-ai-conversation.png" alt="PetAdopt mobile AI Assistant responding to a Turkish lifestyle request with real pet recommendations" width="300"></td>
  </tr>
</table>

### Admin workspace

<table>
  <tr>
    <td width="50%" align="center"><strong>Dashboard</strong></td>
    <td width="50%" align="center"><strong>Pet management</strong></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/admin-dashboard.jpeg" alt="Admin dashboard with platform statistics, review queue, and moderation progress"></td>
    <td><img src="docs/screenshots/admin-pets.jpeg" alt="Admin pet management table with filters, search, and listing actions"></td>
  </tr>
  <tr>
    <td width="50%" align="center"><strong>Create a listing</strong></td>
    <td width="50%" align="center"><strong>Application review</strong></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/admin-add-new-pet.jpeg" alt="Admin dialog for creating a pet listing from the supported pet contract"></td>
    <td><img src="docs/screenshots/admin-applications.jpeg" alt="Admin adoption applications table with status filters and actions"></td>
  </tr>
  <tr>
    <td colspan="2" align="center"><strong>User management</strong></td>
  </tr>
  <tr>
    <td colspan="2"><img src="docs/screenshots/admin-users.jpeg" alt="Admin user management table with roles, search, and account actions"></td>
  </tr>
</table>

## 🏗 Architecture

```mermaid
flowchart LR
    Client["Flutter Web, Mobile & Desktop"]
    API["FastAPI Backend<br/>:8000"]
    AI["AI Service<br/>:8001"]
    DB[("PostgreSQL 16")]
    Claude["Anthropic Claude"]
    Bootstrap["Alembic + Seed"]

    Client -->|"JWT + REST"| API
    Client -->|"AI requests"| AI
    API -->|"SQLAlchemy"| DB
    AI -->|"Read-only pet data"| DB
    AI -->|"Prompted inference"| Claude
    Bootstrap --> DB
```

The backend and AI service are deliberately independent. The AI service can be
restarted, rate-limited or unavailable without taking down the adoption API.
Both services use the same database, while the AI service keeps its access
read-only and does not import backend models.

### Technology stack

| Layer | Technology |
|---|---|
| Client | Flutter, Provider, Dio, go_router, secure storage |
| Backend | Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2 |
| Database | PostgreSQL 16, Alembic migrations |
| Authentication | JWT access and refresh tokens, bcrypt, role-based access |
| AI | Anthropic Claude, versioned prompts, tenacity retries |
| Quality | pytest, Flutter tests, Postman/Newman, GitHub Actions |
| Runtime | Docker Compose |

## 📦 Component Guides

Each application is independently documented with its own architecture,
configuration, commands, endpoints, tests, and project structure.

| Component | Responsibility | Documentation |
|---|---|---|
| [![Backend](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi&logoColor=white)](backend/README.md) | Authentication, pets, categories, favourites, adoptions, uploads, and admin APIs | [Open backend guide →](backend/README.md) |
| [![AI](https://img.shields.io/badge/AI-Anthropic_Claude-D97757)](ai/README.md) | Descriptions, recommendations, image classification, and assistant routing | [Open AI guide →](ai/README.md) |
| [![Frontend](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter&logoColor=white)](frontend/README.md) | Responsive adopter experience, AI chat, profile flows, and admin workspace | [Open frontend guide →](frontend/README.md) |

## 🚀 Quick Start

### Prerequisites

- Docker Desktop
- An Anthropic API key
- Flutter SDK for running the client locally

### Run the full stack

Create the root environment file:

```bash
cp .env.example .env
```

Set the required secrets:

```env
ANTHROPIC_API_KEY=sk-ant-...
SECRET_KEY=replace-with-a-long-random-secret
```

Start PostgreSQL, migrations, seed, backend and AI services:

```bash
docker compose up --build
```

| Service | URL |
|---|---|
| Backend API | http://localhost:8000 |
| Swagger UI | http://localhost:8000/docs |
| AI service | http://localhost:8001 |
| AI Swagger UI | http://localhost:8001/docs |

Run the Flutter client in a second terminal:

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

<details>
<summary><strong>Run services individually</strong></summary>

Start only PostgreSQL with `docker compose up -d db`, then run each service
from its own directory:

```bash
cd backend
pip install -r requirements.txt
python -m alembic upgrade head
python seed.py
python -m uvicorn app.main:app --reload --port 8000
```

```bash
cd ai
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8001
```

</details>

### Local demo accounts

| Role | Email | Password |
|---|---|---|
| Admin | `bilge@hotmail.com` | `Bilge1234` |
| Admin | `arjin@outlook.com` | `Arjin2026` |

The seed creates 35 pets across five species, five categories, adoption
applications in every supported status, favourites and pending user listings.
Running the seed resets the dataset to a known state.

## 🔐 API and Permissions

### Authentication flow

- `POST /auth/register` creates a regular user.
- `POST /auth/login` returns access and refresh tokens.
- `POST /auth/refresh` rotates authentication tokens.
- Access tokens expire after 15 minutes; refresh tokens expire after 7 days.
- Roles are read from the database on every request, so demotion takes effect
  immediately instead of waiting for a token to expire.

### Permission matrix

| Resource | Public | Authenticated user | Admin |
|---|---|---|---|
| Auth | Register, login, refresh | — | — |
| Pets | List and view approved pets | Create, manage own listings, upload photos | Review pending pets, approve, delete |
| Categories | List and view | — | Create, update, delete |
| Adoptions | — | Apply, list and view own applications | View all, update status |
| Users | — | View own profile | List, update roles, delete |
| Favourites | — | Add, list, remove | — |

Invisible records return `404` to avoid leaking their existence. Visible
records that the caller cannot modify return `403`. Validation and service
errors use the RFC 7807 `application/problem+json` format.

### AI endpoints

| Endpoint | Purpose |
|---|---|
| `POST /generate-description` | Generate a natural adoption listing from pet attributes |
| `POST /recommend-pet` | Match adopter lifestyle text with a real, adoptable pet |
| `POST /classify-image` | Identify species and estimate breed from an image |
| `POST /assistant` | Route conversational requests to the appropriate AI capability |

Prompts live in `ai/app/prompts/` as versioned modules. Every prompt exports a
`PROMPT_VERSION`, and the AI client retries only transient failures such as
rate limits, server errors and network interruptions.

## 🎬 Demo Video

A full walkthrough of the adopter flow, the AI assistant and the admin panel:

[![Watch the demo on YouTube](https://img.shields.io/badge/YouTube-Watch_the_demo-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/xPZo9AKaSOs)

## 🧪 Testing and Quality

The repository uses layered testing rather than relying on a single happy
path.

| Suite | Coverage | Command |
|---|---|---|
| Backend | API, permissions, pagination and adoption rules | `cd backend && pytest -q` |
| AI | Routing, prompt output and mocked provider failures | `cd ai && pytest -q` |
| Frontend | Navigation, providers, repositories, pet screens, and admin flows | `cd frontend && flutter test` |
| Live API QA | Positive and negative seeded flows | Newman command below |

```bash
newman run qa/petadopt.postman_collection.json \
  -e qa/petadopt.postman_environment.json \
  -r cli,htmlextra \
  --reporter-htmlextra-export qa/report.html
```

GitHub Actions runs backend, AI and admin frontend test jobs for every pull
request and push to `main`.

### QA evidence

<table>
  <tr>
    <td width="50%" align="center"><strong>Seeded Docker stack</strong></td>
    <td width="50%" align="center"><strong>Newman API report</strong></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/docker-up.png" alt="Docker Compose starting the seeded PetAdopt stack"></td>
    <td><img src="docs/screenshots/newman-report.png" alt="Newman report with 30 requests and 51 passing assertions"></td>
  </tr>
</table>

## 📚 OpenAPI Documentation

FastAPI publishes an OpenAPI 3.1 contract and interactive Swagger UI for the
complete backend surface.

<p align="center">
  <img src="docs/screenshots/api-docs-1.png" alt="PetAdopt Swagger endpoint overview" width="900">
</p>

<details>
<summary><strong>View generated API schemas</strong></summary>

<p align="center">
  <img src="docs/screenshots/api-docs-2.png" alt="PetAdopt OpenAPI schemas" width="900">
</p>

</details>

## 🧠 Technology Choices and Rationale

This section explains why the project made its main technical choices, the
alternatives that were considered, and the trade-offs that were accepted.

### 1. Adoption domain instead of a sales domain

PetAdopt deliberately adapts the classic Petstore model to adoption rather
than retail. The required engineering capabilities—CRUD, pagination, Problem
Details, file uploads, RAG, JSON validation, Docker, and CI—are independent of
the domain; adoption provides a more meaningful context for applying them.

- An AI request such as “I live in an apartment and want a calm cat” is a
  natural shelter-use case rather than an artificial catalogue query.
- Replacing orders with adoption applications introduces a richer workflow:
  `pending → approved → completed`, together with effects such as updating the
  pet's availability.

The trade-off was a small, intentional contract change: one table name, three
fields, and two enums changed after team agreement before implementation.

### 2. Backend: Python and FastAPI

FastAPI was selected because it produces the OpenAPI 3.1 contract from the
application code from the first day. Swagger documentation is therefore not a
separate artifact that can drift from the implementation. Pydantic keeps
request bodies, query parameters, response schemas, and validation in the same
type system, with invalid input automatically producing structured `422`
responses.

Python also keeps the backend and AI services in one language. Although NestJS
and .NET could both implement the API, the AI service necessarily uses Python
SDKs and data tooling. A two-language stack would add separate dependency,
testing, and Docker conventions without a corresponding benefit for this
project's timeline.

### 3. Database: PostgreSQL, SQLAlchemy, and Alembic

PostgreSQL is the production database because the model has seven enum-backed
concepts: species, gender, size, energy level, pet status, application status,
and role. PostgreSQL enforces valid enum values at the database level. Its
ecosystem also integrates naturally with SQLAlchemy and Alembic.

Exact `Numeric(3,1)` and `Numeric(10,2)` columns avoid floating-point rounding
problems for ages and adoption fees. MySQL was a viable alternative, but
PostgreSQL offered stronger enum support and a more established migration
workflow for this stack. SQLite was not used as the application database
because its enum support and schema-alteration behaviour differ from
PostgreSQL.

Foreign keys and service-layer checks serve different purposes. The service
layer returns a clear, domain-specific response to the client, while database
constraints preserve integrity even under concurrent requests.

### 4. AI as an independent service

The AI capability is an independent FastAPI service with its own `main.py`,
requirements, environment file, and Docker image rather than a module inside
the adoption API.

- Provider latency or failure cannot take down core flows such as listing pets
  or signing in.
- AI SDK versions remain isolated from the backend dependency set.
- The service can be scaled separately in a production deployment because its
  CPU and request profile differs from the API.

The cost is two services, two environment files, and two Dockerfiles. Docker
Compose reduces that operational cost to a single startup command.

### 5. How the AI service reads pet data

For RAG context, the AI service reads the database through one read-only query
rather than calling backend HTTP endpoints. This kept real-data recommendations
available while backend routes were still being completed and avoids adding an
HTTP hop, latency, and another failure surface to a read-only operation.

The AI service does not import backend SQLAlchemy models; it owns its query and
keeps the dependency direction narrow. The accepted trade-off is that the
visibility condition—approved and available pets only—exists in both services.
If that business rule changes, both locations must be updated together.

### 6. LLM provider: Claude API

Claude was selected because one provider supports both text generation and the
optional image-classification feature. Its instruction following and structured
JSON output behaviour are especially useful in an architecture that validates
every model response with Pydantic.

The application never trusts raw model output. Description, recommendation, and
image-classification responses are validated against dedicated schemas. The
species field is constrained with a `Literal`, so an out-of-contract species
cannot silently enter the API response.

### 7. Explicit retry policy

The project uses its own retry layer instead of relying solely on SDK defaults.
That makes retry behaviour explicit and testable.

| Failure type | Meaning | Retry? |
|---|---|---|
| `429` | Rate limit | Yes |
| `500` / `529` | Provider error or overload | Yes |
| Network error | Connection interruption | Yes |
| `401` | Invalid API key | No |
| `400` | Invalid request | No |

Retrying permanent failures only delays useful feedback and hides the real
problem. Transient failures use exponential backoff (`1s → 2s → 4s`). Retry
count and delay are safe environment-level configuration values; API keys stay
mandatory and private in `.env` files.

### 8. Versioned prompts

Prompts are versioned files under `ai/app/prompts/` rather than strings embedded
in application code. Files such as `description_v1`, `recommend_v1`, and
`classify_v1` make changes traceable, make rollback possible, and allow output
quality to be compared across prompt versions.

Rules that should never be left to model memory are implemented in code. For
example, the age wording for pets younger than one year is normalised before it
reaches a prompt rather than asking the model to remember the rule.

### 9. One assistant entry point and focused endpoints

`POST /assistant` provides one conversational entry point, while
`/generate-description`, `/recommend-pet`, and `/classify-image` remain
available as focused endpoints. Business logic lives in shared functions; both
the assistant and the focused routes call those functions. This supports a
simple chat experience for the client while keeping QA, evaluation, and admin
integration independently testable.

The assistant is intentionally stateless. The client supplies the complete
message history with each request, so the server does not introduce an
out-of-scope conversation table or retention lifecycle. Recommendations always
refer to a real database pet and its real `photo_url`; the system does not
fabricate adoptable animals or images.

### 10. Authentication: JWT and bcrypt

JWT access and refresh tokens allow web and mobile clients to share a
stateless authentication mechanism across independent services. Access tokens
last 15 minutes and refresh tokens last 7 days; both are rotated during refresh.

Roles are deliberately not embedded in token claims. `get_current_user` already
looks up the current user, so reading the role from the database adds no extra
lookup and ensures that role changes take effect immediately. A deleted user
with an otherwise valid token receives `401`.

Refresh tokens are stateless and therefore cannot be individually revoked
without an additional blacklist. The `jti` claim leaves a clear extension path
for blacklist support later. Passwords are hashed with bcrypt in the service
layer, never stored or returned in plain text. Password reset and email
verification flows are intentionally outside the project scope.

### 11. Error format: Problem Details

The API uses RFC 7807 Problem Details with the
`application/problem+json` media type and the `type`, `title`, `status`,
`detail`, and `instance` fields. Clients can use one error model and display
the user-facing explanation from `detail`.

An invisible record returns `404`, not `403`, so an unapproved listing is not
revealed to another user. Attempting to modify someone else's already-visible
listing returns `403`, because its existence is not private.

### 12. API naming and precision decisions

The pagination parameter is named `per_page`, not `size`, because `size` is
already a pet attribute (`small`, `medium`, or `large`). This avoids ambiguous
requests such as `GET /pets?size=large` and was communicated as a client-facing
breaking contract change.

Decimal `age` and `adoption_fee` values are serialised as strings. This
preserves `Decimal` precision across JSON boundaries; clients explicitly parse
the values when they need numeric presentation or calculations.

### 13. Testing strategy

Backend tests use in-memory SQLite for speed and isolation: they need neither a
live database nor an API key, and run in seconds in CI. PostgreSQL-specific
migration confidence is maintained separately by validating the
`upgrade → downgrade → upgrade` cycle against PostgreSQL.

LLM calls are mocked so CI does not spend money, require a provider key, or
become flaky because of nondeterministic model output. pytest validates the API
at code level, while the Postman/Newman collection validates seeded live flows
as a black-box client. The two layers test different risks.

### 14. Docker and continuous integration

Docker Compose starts PostgreSQL, the backend, and the AI service together.
Dependent services wait for the database health check, and a named volume keeps
data after `docker compose down`. The goal is for a new contributor to start
the stack without manually coordinating infrastructure.

GitHub Actions runs the backend, AI, and admin frontend test jobs for every
pull request and push to `main`. Seeded pet images are stored locally under
`uploads/pets/` rather than loaded from third-party URLs. This avoids hotlink
and CORS failures and keeps demos independent of external image hosting.

### Summary

| Area | Choice | Primary reason |
|---|---|---|
| Backend | Python + FastAPI | Automatic OpenAPI, Pydantic validation, one language with AI |
| Database | PostgreSQL | Native enums, Alembic compatibility, precise decimals |
| ORM and migrations | SQLAlchemy + Alembic | Versioned, repeatable schema changes |
| AI architecture | Separate FastAPI service | Independent failure domain, dependencies, and scaling |
| LLM | Claude API | Vision support and structured output from one provider |
| Retry | Explicit custom policy | Controlled retryability for each failure type |
| Authentication | JWT + bcrypt | Stateless authentication for two client types and services |
| Error format | Problem Details (RFC 7807) | Standardised, consistent client errors |
| Testing | pytest/SQLite + Newman | Fast isolated checks plus live black-box validation |
| Runtime | Docker Compose | One-command full-stack startup |

## 🗂 Repository Structure

```text
pet-adopt/
├── backend/             FastAPI adoption API, migrations and seed
├── ai/                  Independent Claude-powered AI service
├── frontend/            Flutter web, mobile and desktop client
├── qa/                  Postman collection and QA plans
├── docs/screenshots/    API, Docker and test evidence
├── .agents/skills/      Reusable project workflow skill
├── .github/workflows/   Continuous integration
└── docker-compose.yml   Full-stack orchestration
```

See the [component guides](#-component-guides) for service-specific setup and
development instructions.

## 👥 Team

| Area | Owner |
|---|---|
| Backend — models, migrations, seed, services and API | Bilge |
| AI service, Docker and backend QA | Bilge |
| Flutter client — admin panel | Bilge |
| Flutter client — user-facing experience | Arjin |

## 🤝 Workflow

- Branches follow `feature/issue-NN-slug` or `fix/issue-NN-slug`.
- Pull requests link their issue with `Closes #NN` only when all mandatory work
  is complete.
- Commits follow Conventional Commits.
- Secrets stay in ignored `.env` files.
- Project work is tracked on the
  [PetAdopt GitHub Project](https://github.com/users/bilgenurpala/projects/8/views/1).

---

<div align="center">

Built for the **VBT Internship 2026** program.

</div>
