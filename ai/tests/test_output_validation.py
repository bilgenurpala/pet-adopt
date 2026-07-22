import base64
import json

import pytest

from tests.conftest import PIXEL


DESCRIPTION_REQUEST = {
    "name": "Duman",
    "species": "cat",
    "breed": "British Shorthair",
    "age": "3.0",
    "gender": "male",
    "size": "medium",
    "energy_level": "low",
}


def test_broken_description_output_returns_502(client, monkeypatch):
    monkeypatch.setattr(
        "app.services.description_service.ask_claude",
        lambda prompt, system=None, max_tokens=1024: "sorry, I have no JSON for you",
    )

    response = client.post("/generate-description", json=DESCRIPTION_REQUEST)

    assert response.status_code == 502
    assert response.status_code != 500


def test_broken_recommend_output_returns_502(client, monkeypatch, pets):
    monkeypatch.setattr(
        "app.services.recommend_service.get_adoptable_pets", lambda: pets
    )
    monkeypatch.setattr(
        "app.services.recommend_service.ask_claude",
        lambda prompt, system=None, max_tokens=1024: "no json here",
    )

    response = client.post("/recommend-pet", json={"preferences": "a calm cat"})

    assert response.status_code == 502


def test_broken_classify_output_returns_502(client, monkeypatch):
    monkeypatch.setattr(
        "app.services.classify_service.ask_claude_vision",
        lambda prompt, image_base64, media_type, system=None, max_tokens=1024: "not json",
    )

    response = client.post(
        "/classify-image",
        files={"file": ("cat.png", base64.b64decode(PIXEL), "image/png")},
    )

    assert response.status_code == 502


def test_out_of_set_species_returns_502(client, monkeypatch):
    monkeypatch.setattr(
        "app.services.classify_service.ask_claude_vision",
        lambda prompt, image_base64, media_type, system=None, max_tokens=1024: json.dumps(
            {"species": "dragon", "breed_guess": "mythical", "confidence": 0.7}
        ),
    )

    response = client.post(
        "/classify-image",
        files={"file": ("cat.png", base64.b64decode(PIXEL), "image/png")},
    )

    assert response.status_code == 502


def test_no_animal_image_returns_other_and_zero_confidence(client, monkeypatch):
    monkeypatch.setattr(
        "app.services.classify_service.ask_claude_vision",
        lambda prompt, image_base64, media_type, system=None, max_tokens=1024: json.dumps(
            {"species": "other", "breed_guess": "none", "confidence": 0.0}
        ),
    )

    response = client.post(
        "/classify-image",
        files={"file": ("wall.png", base64.b64decode(PIXEL), "image/png")},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["species"] == "other"
    assert body["confidence"] == 0.0


def test_empty_description_request_returns_422(client):
    response = client.post("/generate-description", json={})

    assert response.status_code == 422
