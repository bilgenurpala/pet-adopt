def test_add_favorite_returns_pet(client, auth, user_token, registered_user, make_pet):
    pet = make_pet(registered_user["id"], is_approved=True)

    response = client.post(
        "/favorites", json={"pet_id": pet.id}, headers=auth(user_token)
    )

    assert response.status_code == 201
    assert response.json()["id"] == pet.id


def test_add_favorite_requires_authentication(client, registered_user, make_pet):
    pet = make_pet(registered_user["id"], is_approved=True)

    response = client.post("/favorites", json={"pet_id": pet.id})

    assert response.status_code == 401


def test_add_favorite_unknown_pet_returns_404(client, auth, user_token):
    response = client.post(
        "/favorites", json={"pet_id": 999999}, headers=auth(user_token)
    )

    assert response.status_code == 404


def test_add_favorite_twice_returns_409(
    client, auth, user_token, registered_user, make_pet
):
    pet = make_pet(registered_user["id"], is_approved=True)
    headers = auth(user_token)

    assert client.post("/favorites", json={"pet_id": pet.id}, headers=headers).status_code == 201
    response = client.post("/favorites", json={"pet_id": pet.id}, headers=headers)

    assert response.status_code == 409


def test_two_users_can_favorite_the_same_pet(
    client, auth, user_token, other_user, registered_user, make_pet
):
    pet = make_pet(registered_user["id"], is_approved=True)

    first = client.post(
        "/favorites", json={"pet_id": pet.id}, headers=auth(user_token)
    )
    second = client.post(
        "/favorites", json={"pet_id": pet.id}, headers=auth(other_user["token"])
    )

    assert first.status_code == 201
    assert second.status_code == 201


def test_remove_favorite(client, auth, user_token, registered_user, make_pet):
    pet = make_pet(registered_user["id"], is_approved=True)
    headers = auth(user_token)
    client.post("/favorites", json={"pet_id": pet.id}, headers=headers)

    response = client.delete(f"/favorites/{pet.id}", headers=headers)

    assert response.status_code == 204
    assert client.get("/favorites", headers=headers).json()["total"] == 0


def test_remove_favorite_that_does_not_exist_returns_404(
    client, auth, user_token, registered_user, make_pet
):
    pet = make_pet(registered_user["id"], is_approved=True)

    response = client.delete(f"/favorites/{pet.id}", headers=auth(user_token))

    assert response.status_code == 404


def test_list_favorites_returns_pet_details(
    client, auth, user_token, registered_user, make_pet
):
    pet = make_pet(registered_user["id"], name="Boncuk", is_approved=True)
    headers = auth(user_token)
    client.post("/favorites", json={"pet_id": pet.id}, headers=headers)

    response = client.get("/favorites", headers=headers)

    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["name"] == "Boncuk"


def test_list_favorites_is_scoped_to_current_user(
    client, auth, user_token, other_user, registered_user, make_pet
):
    pet = make_pet(registered_user["id"], is_approved=True)
    client.post("/favorites", json={"pet_id": pet.id}, headers=auth(user_token))

    response = client.get("/favorites", headers=auth(other_user["token"]))

    assert response.status_code == 200
    assert response.json()["total"] == 0


def test_list_favorites_is_paginated(
    client, auth, user_token, registered_user, make_pet
):
    headers = auth(user_token)
    for index in range(3):
        pet = make_pet(registered_user["id"], name=f"Pet {index}", is_approved=True)
        client.post("/favorites", json={"pet_id": pet.id}, headers=headers)

    response = client.get("/favorites?page=2&per_page=2", headers=headers)

    body = response.json()
    assert body["total"] == 3
    assert body["page"] == 2
    assert body["per_page"] == 2
    assert len(body["items"]) == 1


def test_list_favorites_requires_authentication(client):
    assert client.get("/favorites").status_code == 401
