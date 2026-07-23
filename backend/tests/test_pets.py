import io

from app.models.enums import EnergyLevel, PetStatus, Size, Species


def photo(name="cat.jpg", content=b"fake-image-bytes"):
    return {"file": (name, io.BytesIO(content), "image/jpeg")}


class TestListPets:
    def test_only_approved_pets_are_listed(self, client, registered_user, make_pet):
        make_pet(registered_user["id"], name="Approved", is_approved=True)
        make_pet(registered_user["id"], name="Waiting", is_approved=False)

        body = client.get("/pets").json()

        assert body["total"] == 1
        assert [item["name"] for item in body["items"]] == ["Approved"]

    def test_owner_does_not_see_their_unapproved_pet_in_the_list(
        self, client, auth, registered_user, user_token, make_pet
    ):
        make_pet(registered_user["id"], name="Waiting", is_approved=False)

        body = client.get("/pets", headers=auth(user_token)).json()

        assert body["total"] == 0

    def test_admin_does_not_see_unapproved_pets_in_the_list(
        self, client, auth, admin, registered_user, make_pet
    ):
        make_pet(registered_user["id"], is_approved=False)

        body = client.get("/pets", headers=auth(admin["token"])).json()

        assert body["total"] == 0

    def test_filters_narrow_the_result(self, client, registered_user, make_pet):
        make_pet(registered_user["id"], species=Species.DOG, is_approved=True)
        make_pet(registered_user["id"], species=Species.CAT, is_approved=True)

        body = client.get("/pets", params={"species": "cat"}).json()

        assert body["total"] == 1
        assert body["items"][0]["species"] == "cat"

    def test_filters_combine(self, client, registered_user, make_pet):
        make_pet(
            registered_user["id"],
            species=Species.DOG,
            size=Size.SMALL,
            energy_level=EnergyLevel.LOW,
            is_approved=True,
        )
        make_pet(
            registered_user["id"],
            species=Species.DOG,
            size=Size.LARGE,
            energy_level=EnergyLevel.LOW,
            is_approved=True,
        )

        body = client.get(
            "/pets", params={"species": "dog", "size": "large"}
        ).json()

        assert body["total"] == 1
        assert body["items"][0]["size"] == "large"

    def test_status_filter_uses_the_public_name(self, client, registered_user, make_pet):
        make_pet(registered_user["id"], status=PetStatus.ADOPTED, is_approved=True)
        make_pet(registered_user["id"], status=PetStatus.AVAILABLE, is_approved=True)

        body = client.get("/pets", params={"status": "adopted"}).json()

        assert body["total"] == 1

    def test_unknown_filter_value_is_rejected(self, client):
        assert client.get("/pets", params={"species": "dragon"}).status_code == 422

    def test_pagination_splits_the_result(self, client, registered_user, make_pet):
        for index in range(5):
            make_pet(registered_user["id"], name=f"Pet {index}", is_approved=True)

        body = client.get("/pets", params={"page": 2, "per_page": 2}).json()

        assert body["total"] == 5
        assert body["page"] == 2
        assert len(body["items"]) == 2

    def test_page_size_is_capped(self, client):
        assert client.get("/pets", params={"per_page": 500}).status_code == 422

    def test_size_filter_and_page_size_do_not_collide(
        self, client, registered_user, make_pet
    ):
        make_pet(registered_user["id"], size=Size.LARGE, is_approved=True)
        make_pet(registered_user["id"], size=Size.SMALL, is_approved=True)

        body = client.get("/pets", params={"size": "large", "per_page": 1}).json()

        assert body["total"] == 1
        assert body["per_page"] == 1


class TestGetPet:
    def test_approved_pet_is_public(self, client, registered_user, make_pet):
        pet = make_pet(registered_user["id"], is_approved=True)

        assert client.get(f"/pets/{pet.id}").status_code == 200

    def test_unapproved_pet_is_hidden_from_anonymous_visitors(
        self, client, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=False)

        assert client.get(f"/pets/{pet.id}").status_code == 404

    def test_unapproved_pet_is_visible_to_its_owner(
        self, client, auth, registered_user, user_token, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=False)

        response = client.get(f"/pets/{pet.id}", headers=auth(user_token))

        assert response.status_code == 200
        assert response.json()["is_approved"] is False

    def test_unapproved_pet_is_visible_to_an_admin(
        self, client, auth, admin, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=False)

        assert (
            client.get(f"/pets/{pet.id}", headers=auth(admin["token"])).status_code
            == 200
        )

    def test_unapproved_pet_is_hidden_from_another_user(
        self, client, auth, other_user, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=False)

        assert (
            client.get(f"/pets/{pet.id}", headers=auth(other_user["token"])).status_code
            == 404
        )

    def test_missing_pet_returns_problem_details(self, client):
        response = client.get("/pets/9999")

        assert response.status_code == 404
        assert response.headers["content-type"] == "application/problem+json"


class TestCreatePet:
    def test_anonymous_visitors_cannot_create(self, client, pet_payload):
        assert client.post("/pets", json=pet_payload).status_code == 401

    def test_owner_id_comes_from_the_token(
        self, client, auth, user_token, registered_user, other_user, pet_payload
    ):
        response = client.post(
            "/pets",
            json={**pet_payload, "owner_id": other_user["id"]},
            headers=auth(user_token),
        )

        assert response.status_code == 201
        assert response.json()["owner_id"] == registered_user["id"]

    def test_a_user_listing_starts_unapproved(
        self, client, auth, user_token, pet_payload
    ):
        response = client.post(
            "/pets",
            json={**pet_payload, "is_approved": True},
            headers=auth(user_token),
        )

        assert response.json()["is_approved"] is False

    def test_an_admin_listing_starts_approved(
        self, client, auth, admin, pet_payload
    ):
        response = client.post("/pets", json=pet_payload, headers=auth(admin["token"]))

        assert response.json()["is_approved"] is True

    def test_status_cannot_be_set_by_the_client(
        self, client, auth, user_token, pet_payload
    ):
        response = client.post(
            "/pets",
            json={**pet_payload, "status": "adopted"},
            headers=auth(user_token),
        )

        assert response.json()["status"] == PetStatus.AVAILABLE.value

    def test_unknown_category_is_rejected(self, client, auth, user_token, pet_payload):
        response = client.post(
            "/pets", json={**pet_payload, "category_id": 9999}, headers=auth(user_token)
        )

        assert response.status_code == 422

    def test_negative_age_is_rejected(self, client, auth, user_token, pet_payload):
        response = client.post(
            "/pets", json={**pet_payload, "age": "-1.0"}, headers=auth(user_token)
        )

        assert response.status_code == 422


class TestUpdatePet:
    def test_owner_can_update(
        self, client, auth, user_token, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        response = client.patch(
            f"/pets/{pet.id}", json={"name": "Yeni"}, headers=auth(user_token)
        )

        assert response.status_code == 200
        assert response.json()["name"] == "Yeni"

    def test_admin_can_update_any_pet(
        self, client, auth, admin, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        response = client.patch(
            f"/pets/{pet.id}", json={"name": "Admin"}, headers=auth(admin["token"])
        )

        assert response.status_code == 200

    def test_another_user_is_forbidden(
        self, client, auth, other_user, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        response = client.patch(
            f"/pets/{pet.id}", json={"name": "Hack"}, headers=auth(other_user["token"])
        )

        assert response.status_code == 403

    def test_an_invisible_pet_looks_missing_rather_than_forbidden(
        self, client, auth, other_user, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=False)

        response = client.patch(
            f"/pets/{pet.id}", json={"name": "Hack"}, headers=auth(other_user["token"])
        )

        assert response.status_code == 404

    def test_status_is_not_accepted(
        self, client, auth, user_token, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        response = client.patch(
            f"/pets/{pet.id}", json={"status": "adopted"}, headers=auth(user_token)
        )

        assert response.json()["status"] == PetStatus.AVAILABLE.value

    def test_approval_cannot_be_granted_through_update(
        self, client, auth, user_token, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=False)

        response = client.patch(
            f"/pets/{pet.id}", json={"is_approved": True}, headers=auth(user_token)
        )

        assert response.json()["is_approved"] is False


class TestDeletePet:
    def test_owner_can_delete(self, client, auth, user_token, registered_user, make_pet):
        pet = make_pet(registered_user["id"], is_approved=True)

        assert (
            client.delete(f"/pets/{pet.id}", headers=auth(user_token)).status_code == 204
        )
        assert client.get(f"/pets/{pet.id}").status_code == 404

    def test_admin_can_delete_any_pet(
        self, client, auth, admin, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        assert (
            client.delete(f"/pets/{pet.id}", headers=auth(admin["token"])).status_code
            == 204
        )

    def test_another_user_cannot_delete(
        self, client, auth, other_user, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        assert (
            client.delete(
                f"/pets/{pet.id}", headers=auth(other_user["token"])
            ).status_code
            == 403
        )

def test_a_pet_with_an_application_cannot_be_deleted(
        self, client, auth, admin, other_user, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)
        client.post(
            "/adoptions",
            json={"pet_id": pet.id},
            headers=auth(other_user["token"]),
        )

        response = client.delete(
            f"/pets/{pet.id}", headers=auth(admin["token"])
        )

        assert response.status_code == 409
        assert "1 application" in response.json()["detail"]

    def test_a_pet_with_a_favorite_cannot_be_deleted(
        self, client, auth, admin, other_user, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)
        client.post(
            "/favorites",
            json={"pet_id": pet.id},
            headers=auth(other_user["token"]),
        )

        response = client.delete(
            f"/pets/{pet.id}", headers=auth(admin["token"])
        )

        assert response.status_code == 409
        assert "1 favorite" in response.json()["detail"]
class TestApprovePet:
    def test_admin_can_approve(self, client, auth, admin, registered_user, make_pet):
        pet = make_pet(registered_user["id"], is_approved=False)

        response = client.patch(
            f"/pets/{pet.id}/approve", headers=auth(admin["token"])
        )

        assert response.status_code == 200
        assert response.json()["is_approved"] is True
        assert client.get(f"/pets/{pet.id}").status_code == 200

    def test_owner_cannot_approve_their_own_pet(
        self, client, auth, user_token, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=False)

        response = client.patch(f"/pets/{pet.id}/approve", headers=auth(user_token))

        assert response.status_code == 403

    def test_anonymous_visitors_cannot_approve(
        self, client, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=False)

        assert client.patch(f"/pets/{pet.id}/approve").status_code == 401

    def test_missing_pet_returns_404(self, client, auth, admin):
        assert (
            client.patch("/pets/9999/approve", headers=auth(admin["token"])).status_code
            == 404
        )


class TestUploadPhoto:
    def test_owner_can_upload_a_photo(
        self, client, auth, user_token, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        response = client.post(
            f"/pets/{pet.id}/photo", files=photo(), headers=auth(user_token)
        )

        assert response.status_code == 200
        assert response.json()["photo_url"].startswith("/uploads/")
        assert response.json()["photo_url"].endswith(".jpg")

    def test_unsupported_extension_is_rejected(
        self, client, auth, user_token, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        response = client.post(
            f"/pets/{pet.id}/photo",
            files=photo(name="virus.exe"),
            headers=auth(user_token),
        )

        assert response.status_code == 422

    def test_oversized_file_is_rejected(
        self, client, auth, user_token, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        response = client.post(
            f"/pets/{pet.id}/photo",
            files=photo(content=b"x" * (5 * 1024 * 1024 + 1)),
            headers=auth(user_token),
        )

        assert response.status_code == 422

    def test_another_user_cannot_upload(
        self, client, auth, other_user, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)

        response = client.post(
            f"/pets/{pet.id}/photo", files=photo(), headers=auth(other_user["token"])
        )

        assert response.status_code == 403
