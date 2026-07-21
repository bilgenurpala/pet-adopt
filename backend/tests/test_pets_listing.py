def test_mine_returns_approved_and_unapproved_pets(
    client, auth, user_token, registered_user, make_pet
):
    make_pet(registered_user["id"], name="Onayli", is_approved=True)
    make_pet(registered_user["id"], name="Bekleyen", is_approved=False)

    response = client.get("/pets/mine", headers=auth(user_token))

    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 2
    assert {item["name"] for item in body["items"]} == {"Onayli", "Bekleyen"}


def test_mine_excludes_other_users_pets(
    client, auth, user_token, other_user, registered_user, make_pet
):
    make_pet(registered_user["id"], name="Benim", is_approved=True)
    make_pet(other_user["id"], name="Baskasinin", is_approved=True)

    response = client.get("/pets/mine", headers=auth(user_token))

    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["name"] == "Benim"


def test_mine_requires_authentication(client):
    assert client.get("/pets/mine").status_code == 401


def test_mine_is_paginated(client, auth, user_token, registered_user, make_pet):
    for index in range(3):
        make_pet(registered_user["id"], name=f"Pet {index}")

    response = client.get("/pets/mine?page=2&per_page=2", headers=auth(user_token))

    body = response.json()
    assert body["total"] == 3
    assert body["page"] == 2
    assert len(body["items"]) == 1


def test_pending_returns_only_unapproved_pets(
    client, auth, admin, registered_user, make_pet
):
    make_pet(registered_user["id"], name="Onayli", is_approved=True)
    make_pet(registered_user["id"], name="Bekleyen", is_approved=False)

    response = client.get("/pets/pending", headers=auth(admin["token"]))

    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["name"] == "Bekleyen"


def test_pending_forbidden_for_regular_user(client, auth, user_token):
    assert client.get("/pets/pending", headers=auth(user_token)).status_code == 403


def test_pending_requires_authentication(client):
    assert client.get("/pets/pending").status_code == 401


def test_pending_is_paginated(client, auth, admin, registered_user, make_pet):
    for index in range(3):
        make_pet(registered_user["id"], name=f"Pet {index}", is_approved=False)

    response = client.get(
        "/pets/pending?page=2&per_page=2", headers=auth(admin["token"])
    )

    body = response.json()
    assert body["total"] == 3
    assert body["page"] == 2
    assert len(body["items"]) == 1


def test_static_routes_are_not_shadowed_by_pet_id_route(
    client, auth, user_token, registered_user, make_pet
):
    pet = make_pet(registered_user["id"], is_approved=True)

    assert client.get("/pets/mine", headers=auth(user_token)).status_code == 200
    assert client.get(f"/pets/{pet.id}").status_code == 200
