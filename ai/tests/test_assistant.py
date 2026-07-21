def post(client, messages):
    return client.post("/assistant", json={"messages": messages})


def test_empty_messages_is_rejected(client):
    response = client.post("/assistant", json={"messages": []})

    assert response.status_code == 422


def test_missing_messages_is_rejected(client):
    response = client.post("/assistant", json={})

    assert response.status_code == 422


def test_response_matches_the_agreed_schema(client, fake_llm, fake_pets):
    fake_llm["state"]["plan"] = {
        "steps": ["recommend"],
        "pet_reference": None,
        "preferences": "calm cat",
    }
    fake_llm["state"]["compose"] = {"reply": "Duman would suit you.", "pet_ids": [1]}

    response = post(client, [{"role": "user", "content": "I want a calm cat"}])

    assert response.status_code == 200
    body = response.json()
    assert set(body) == {"reply", "pets", "action"}
    assert body["reply"] == "Duman would suit you."
    assert body["action"] == "recommend"
    assert len(body["pets"]) == 1

    card = body["pets"][0]
    assert set(card) == {
        "id",
        "name",
        "species",
        "breed",
        "age",
        "gender",
        "size",
        "energy_level",
        "photo_url",
    }
    assert card["id"] == 1
    assert card["name"] == "Duman"
    assert card["photo_url"] == "https://example.com/duman.jpg"
    assert card["age"] == "3 years"


def test_small_talk_does_not_error_and_shows_no_pets(client, fake_llm, fake_pets):
    fake_llm["state"]["plan"] = {
        "steps": ["chat"],
        "pet_reference": None,
        "preferences": "",
    }
    fake_llm["state"]["compose"] = {"reply": "Hello! How can I help?", "pet_ids": []}

    response = post(client, [{"role": "user", "content": "hello"}])

    assert response.status_code == 200
    body = response.json()
    assert body["action"] == "chat"
    assert body["pets"] == []
    assert body["reply"] == "Hello! How can I help?"


def test_image_only_message_runs_classification(client, fake_llm, fake_pets, image_message):
    image_message["content"] = ""

    response = post(client, [image_message])

    assert response.status_code == 200
    assert len(fake_llm["calls"]["vision"]) == 1
    assert "Bengal" in fake_llm["calls"]["compose"][0]


def test_image_makes_action_classify_when_no_pet_is_shown(
    client, fake_llm, fake_pets, image_message
):
    fake_llm["state"]["plan"] = {
        "steps": ["chat"],
        "pet_reference": None,
        "preferences": "",
    }
    fake_llm["state"]["compose"] = {"reply": "That looks like a Bengal.", "pet_ids": []}

    response = post(client, [image_message])

    assert response.json()["action"] == "classify"


def test_image_and_recommendation_in_one_turn(client, fake_llm, fake_pets, image_message):
    fake_llm["state"]["plan"] = {
        "steps": ["recommend"],
        "pet_reference": None,
        "preferences": "calm cat, apartment",
    }
    fake_llm["state"]["compose"] = {
        "reply": "That breed is energetic, so Duman suits you better.",
        "pet_ids": [1],
    }

    response = post(client, [image_message])

    body = response.json()
    assert body["action"] == "recommend"
    assert [pet["id"] for pet in body["pets"]] == [1]
    assert len(fake_llm["calls"]["vision"]) == 1


def test_whole_history_is_sent_to_the_planner(client, fake_llm, fake_pets):
    messages = [
        {"role": "user", "content": "I want a calm cat"},
        {"role": "assistant", "content": "Any size preference?"},
        {"role": "user", "content": "actually make it small"},
        {"role": "assistant", "content": "Noted."},
        {"role": "user", "content": "and my budget is tight"},
    ]

    post(client, messages)

    planner_prompt = fake_llm["calls"]["plan"][0]
    assert "I want a calm cat" in planner_prompt
    assert "actually make it small" in planner_prompt
    assert "budget is tight" in planner_prompt


def test_accumulated_preferences_reach_the_writer(client, fake_llm, fake_pets):
    fake_llm["state"]["plan"] = {
        "steps": ["recommend"],
        "pet_reference": None,
        "preferences": "calm cat, small, low budget",
    }

    post(
        client,
        [
            {"role": "user", "content": "I want a calm cat"},
            {"role": "user", "content": "and small"},
        ],
    )

    assert "calm cat, small, low budget" in fake_llm["calls"]["compose"][0]


def test_no_adoptable_pets_answers_gracefully(client, fake_llm, no_pets):
    fake_llm["state"]["plan"] = {
        "steps": ["recommend"],
        "pet_reference": None,
        "preferences": "calm cat",
    }
    fake_llm["state"]["compose"] = {
        "reply": "There is nothing available right now.",
        "pet_ids": [],
    }

    response = post(client, [{"role": "user", "content": "I want a calm cat"}])

    assert response.status_code == 200
    assert response.json()["pets"] == []
    assert "no pets available" in fake_llm["calls"]["compose"][0].lower()


def test_invented_pet_ids_are_dropped(client, fake_llm, fake_pets):
    fake_llm["state"]["plan"] = {
        "steps": ["recommend"],
        "pet_reference": None,
        "preferences": "calm cat",
    }
    fake_llm["state"]["compose"] = {"reply": "Meet Pamuk.", "pet_ids": [999, 1]}

    response = post(client, [{"role": "user", "content": "I want a calm cat"}])

    assert [pet["id"] for pet in response.json()["pets"]] == [1]


def test_pet_reference_is_resolved_by_name(client, fake_llm, fake_pets):
    fake_llm["state"]["plan"] = {
        "steps": ["answer"],
        "pet_reference": "Duman",
        "preferences": "",
    }
    fake_llm["state"]["compose"] = {"reply": "Duman is 3 years old.", "pet_ids": [1]}

    response = post(client, [{"role": "user", "content": "How old is Duman?"}])

    body = response.json()
    assert body["action"] == "answer"
    assert body["pets"][0]["name"] == "Duman"
    assert "British Shorthair" in fake_llm["calls"]["compose"][0]


def test_broken_planner_output_falls_back_to_chat(client, fake_llm, fake_pets):
    fake_llm["state"]["plan_raw"] = "sorry, I cannot do that"
    fake_llm["state"]["compose"] = {"reply": "How can I help?", "pet_ids": []}

    response = post(client, [{"role": "user", "content": "hello"}])

    assert response.status_code == 200
    assert response.json()["action"] == "chat"


def test_unknown_steps_fall_back_to_chat(client, fake_llm, fake_pets):
    fake_llm["state"]["plan"] = {
        "steps": ["book_a_flight"],
        "pet_reference": None,
        "preferences": "",
    }

    response = post(client, [{"role": "user", "content": "book me a flight"}])

    assert response.status_code == 200
    assert response.json()["action"] == "chat"


def test_broken_writer_output_returns_502(client, fake_llm, fake_pets, monkeypatch):
    monkeypatch.setattr(
        "app.services.assistant_service.ask_claude",
        lambda prompt, system=None, max_tokens=1024: "no json here",
    )

    response = post(client, [{"role": "user", "content": "hello"}])

    assert response.status_code == 502


def test_pet_descriptions_are_truncated_in_the_prompt(client, fake_llm, fake_pets):
    fake_pets[0]["description"] = "x" * 500

    post(client, [{"role": "user", "content": "I want a calm cat"}])

    assert "x" * 500 not in fake_llm["calls"]["compose"][0]
    assert "..." in fake_llm["calls"]["compose"][0]
