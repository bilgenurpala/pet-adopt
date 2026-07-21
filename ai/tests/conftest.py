import json
import os
import sys
from decimal import Decimal
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

os.environ.setdefault("ANTHROPIC_API_KEY", "test-key-not-used")
os.environ.setdefault("DATABASE_URL", "postgresql+psycopg2://test:test@localhost:5432/test")

from app.main import app
from app.services import assistant_service

PIXEL = (
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk"
    "YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
)


@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def pets():
    return [
        {
            "id": 1,
            "name": "Duman",
            "species": "cat",
            "breed": "British Shorthair",
            "age": Decimal("3.0"),
            "gender": "male",
            "size": "medium",
            "energy_level": "low",
            "adoption_fee": Decimal("0.00"),
            "description": "A calm indoor cat who sleeps most of the day.",
            "photo_url": "https://example.com/duman.jpg",
        },
        {
            "id": 2,
            "name": "Zeytin",
            "species": "dog",
            "breed": "Border Collie",
            "age": Decimal("1.5"),
            "gender": "female",
            "size": "large",
            "energy_level": "high",
            "adoption_fee": Decimal("500.00"),
            "description": "Needs a garden and a lot of running.",
            "photo_url": "https://example.com/zeytin.jpg",
        },
    ]


@pytest.fixture
def fake_llm(monkeypatch):
    calls = {"plan": [], "compose": [], "vision": []}

    state = {
        "plan": {"steps": ["chat"], "pet_reference": None, "preferences": ""},
        "compose": {"reply": "Hello from the shelter.", "pet_ids": []},
        "vision": {"species": "cat", "breed_guess": "Bengal", "confidence": 0.9},
        "plan_raw": None,
    }

    def fake_ask_claude(prompt: str, system: str | None = None, max_tokens: int = 1024):
        if "routing component" in (system or ""):
            calls["plan"].append(prompt)
            if state["plan_raw"] is not None:
                return state["plan_raw"]
            return json.dumps(state["plan"])
        calls["compose"].append(prompt)
        return json.dumps(state["compose"])

    def fake_ask_claude_vision(prompt, image_base64, media_type, system=None, max_tokens=1024):
        calls["vision"].append(image_base64)
        return json.dumps(state["vision"])

    monkeypatch.setattr(assistant_service, "ask_claude", fake_ask_claude)
    monkeypatch.setattr(
        "app.services.classify_service.ask_claude_vision", fake_ask_claude_vision
    )

    return {"calls": calls, "state": state}


@pytest.fixture
def fake_pets(monkeypatch, pets):
    monkeypatch.setattr(assistant_service, "get_adoptable_pets", lambda: pets)
    return pets


@pytest.fixture
def no_pets(monkeypatch):
    monkeypatch.setattr(assistant_service, "get_adoptable_pets", lambda: [])


@pytest.fixture
def image_message():
    return {
        "role": "user",
        "content": "Is this the kind of cat I want?",
        "image": {"media_type": "image/png", "data": PIXEL},
    }
