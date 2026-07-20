from app.models.category import Category


class TestListCategories:
    def test_list_is_public_and_paginated(self, client, category):
        response = client.get("/categories")

        assert response.status_code == 200
        body = response.json()
        assert body["total"] == 1
        assert body["per_page"] == 10
        assert body["items"][0]["name"] == category.name

    def test_detail_is_public(self, client, category):
        response = client.get(f"/categories/{category.id}")

        assert response.status_code == 200
        assert response.json()["id"] == category.id

    def test_missing_category_returns_404(self, client):
        response = client.get("/categories/9999")

        assert response.status_code == 404
        assert response.headers["content-type"] == "application/problem+json"


class TestCreateCategory:
    def test_admin_can_create(self, client, auth, admin):
        response = client.post(
            "/categories", json={"name": "Birds"}, headers=auth(admin["token"])
        )

        assert response.status_code == 201
        assert response.json()["name"] == "Birds"

    def test_regular_user_is_forbidden(self, client, auth, user_token):
        response = client.post(
            "/categories", json={"name": "Birds"}, headers=auth(user_token)
        )

        assert response.status_code == 403

    def test_anonymous_visitors_are_rejected(self, client):
        assert client.post("/categories", json={"name": "Birds"}).status_code == 401

    def test_duplicate_name_is_rejected(self, client, auth, admin, category):
        response = client.post(
            "/categories", json={"name": category.name}, headers=auth(admin["token"])
        )

        assert response.status_code == 409

    def test_missing_name_is_rejected(self, client, auth, admin):
        assert (
            client.post("/categories", json={}, headers=auth(admin["token"])).status_code
            == 422
        )


class TestUpdateCategory:
    def test_admin_can_rename(self, client, auth, admin, category):
        response = client.patch(
            f"/categories/{category.id}",
            json={"name": "Renamed"},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 200
        assert response.json()["name"] == "Renamed"

    def test_keeping_its_own_name_is_allowed(self, client, auth, admin, category):
        response = client.patch(
            f"/categories/{category.id}",
            json={"name": category.name},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 200

    def test_taking_another_categorys_name_is_rejected(
        self, client, auth, admin, db, category
    ):
        other = Category(name="Birds")
        db.add(other)
        db.commit()
        db.refresh(other)

        response = client.patch(
            f"/categories/{other.id}",
            json={"name": category.name},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 409

    def test_regular_user_is_forbidden(self, client, auth, user_token, category):
        response = client.patch(
            f"/categories/{category.id}",
            json={"name": "Hack"},
            headers=auth(user_token),
        )

        assert response.status_code == 403


class TestDeleteCategory:
    def test_admin_can_delete_an_empty_category(self, client, auth, admin, category):
        response = client.delete(
            f"/categories/{category.id}", headers=auth(admin["token"])
        )

        assert response.status_code == 204
        assert client.get(f"/categories/{category.id}").status_code == 404

    def test_a_category_with_listings_cannot_be_deleted(
        self, client, auth, admin, category, registered_user, make_pet
    ):
        make_pet(registered_user["id"], is_approved=True)

        response = client.delete(
            f"/categories/{category.id}", headers=auth(admin["token"])
        )

        assert response.status_code == 409
        assert "1 listing" in response.json()["detail"]

    def test_regular_user_is_forbidden(self, client, auth, user_token, category):
        response = client.delete(
            f"/categories/{category.id}", headers=auth(user_token)
        )

        assert response.status_code == 403

    def test_missing_category_returns_404(self, client, auth, admin):
        assert (
            client.delete("/categories/9999", headers=auth(admin["token"])).status_code
            == 404
        )
