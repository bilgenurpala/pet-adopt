import json

import pytest

from tests.conftest import PIXEL


@pytest.fixture
def fake_text_llm(monkeypatch):
    payloads = {}

    def fake_ask_claude(prompt: str, system: str | None = None, max_tokens: int = 1024):
        return json.dumps(payloads["value"])

    monkeypatch.setattr("app.services.description_service.ask_claude", fake_ask_claude)
    monkeypatch.setattr("app.services.recommend_service.ask_claude", fake_ask_claude)
    return payloads


def test_health(client):
    assert client.get("/health").json() == {"status": "ok"}


def test_generate_description_still_works(client, fake_text_llm):
    fake_text_llm["value"] = {"title": "Meet Duman", "description": "A calm cat."}

    response = client.post(
        "/generate-description",
        json={
            "name": "Duman",
            "species": "cat",
            "breed": "British Shorthair",
            "age": "3.0",
            "gender": "male",
            "size": "medium",
            "energy_level": "low",
        },
    )

    assert response.status_code == 200
    assert response.json() == {"title": "Meet Duman", "description": "A calm cat."}


def test_recommend_pet_still_works(client, fake_text_llm, monkeypatch, pets):
    monkeypatch.setattr("app.services.recommend_service.get_adoptable_pets", lambda: pets)
    fake_text_llm["value"] = {"pet_id": 1, "reason": "Calm and indoor."}

    response = client.post("/recommend-pet", json={"preferences": "a calm cat"})

    assert response.status_code == 200
    body = response.json()
    assert body["pet_id"] == 1
    assert body["name"] == "Duman"
    assert body["photo_url"] == "https://example.com/duman.jpg"


def test_recommend_pet_rejects_a_pet_outside_the_list(
    client, fake_text_llm, monkeypatch, pets
):
    monkeypatch.setattr("app.services.recommend_service.get_adoptable_pets", lambda: pets)
    fake_text_llm["value"] = {"pet_id": 999, "reason": "Invented."}

    response = client.post("/recommend-pet", json={"preferences": "a calm cat"})

    assert response.status_code == 502


def test_recommend_pet_without_any_pets_returns_404(client, fake_text_llm, monkeypatch):
    monkeypatch.setattr("app.services.recommend_service.get_adoptable_pets", lambda: [])

    response = client.post("/recommend-pet", json={"preferences": "a calm cat"})

    assert response.status_code == 404


def test_classify_image_still_works(client, monkeypatch):
    import base64

    monkeypatch.setattr(
        "app.services.classify_service.ask_claude_vision",
        lambda prompt, image_base64, media_type, system=None, max_tokens=1024: json.dumps(
            {"species": "cat", "breed_guess": "Bengal", "confidence": 0.9}
        ),
    )

    response = client.post(
        "/classify-image",
        files={"file": ("cat.png", base64.b64decode(PIXEL), "image/png")},
    )

    assert response.status_code == 200
    assert response.json()["species"] == "cat"


def test_classify_image_rejects_wrong_type(client):
    response = client.post(
        "/classify-image",
        files={"file": ("notes.txt", b"hello", "text/plain")},
    )

    assert response.status_code == 415
