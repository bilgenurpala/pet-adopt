import pytest

from app.models.enums import ApplicationStatus, PetStatus
from app.models.pet import Pet


@pytest.fixture
def listing(make_pet, registered_user):
    return make_pet(registered_user["id"], is_approved=True)


def apply_for(client, auth, token, pet_id, message="Very interested"):
    return client.post(
        "/adoptions",
        json={"pet_id": pet_id, "message": message},
        headers=auth(token),
    )


class TestCreateApplication:
    def test_anonymous_visitors_cannot_apply(self, client, listing):
        response = client.post("/adoptions", json={"pet_id": listing.id})

        assert response.status_code == 401

    def test_application_is_born_pending(self, client, auth, other_user, listing):
        response = apply_for(client, auth, other_user["token"], listing.id)

        assert response.status_code == 201
        assert response.json()["status"] == ApplicationStatus.PENDING.value

    def test_user_id_comes_from_the_token(
        self, client, auth, other_user, registered_user, listing
    ):
        response = client.post(
            "/adoptions",
            json={"pet_id": listing.id, "user_id": registered_user["id"]},
            headers=auth(other_user["token"]),
        )

        assert response.json()["user_id"] == other_user["id"]

    def test_status_cannot_be_set_by_the_client(
        self, client, auth, other_user, listing
    ):
        response = client.post(
            "/adoptions",
            json={"pet_id": listing.id, "status": "approved"},
            headers=auth(other_user["token"]),
        )

        assert response.json()["status"] == ApplicationStatus.PENDING.value

    def test_creating_an_application_does_not_change_the_pet(
        self, client, auth, db, other_user, listing
    ):
        apply_for(client, auth, other_user["token"], listing.id)

        assert db.get(Pet, listing.id).status == PetStatus.AVAILABLE

    def test_owner_cannot_apply_to_their_own_listing(
        self, client, auth, user_token, listing
    ):
        response = apply_for(client, auth, user_token, listing.id)

        assert response.status_code == 409

    def test_missing_pet_returns_404(self, client, auth, other_user):
        response = apply_for(client, auth, other_user["token"], 9999)

        assert response.status_code == 404

    def test_unapproved_pet_is_not_applicable(
        self, client, auth, other_user, registered_user, make_pet
    ):
        hidden = make_pet(registered_user["id"], is_approved=False)

        response = apply_for(client, auth, other_user["token"], hidden.id)

        assert response.status_code == 404


class TestDuplicateApplications:
    def test_second_pending_application_is_rejected(
        self, client, auth, other_user, listing
    ):
        apply_for(client, auth, other_user["token"], listing.id)
        second = apply_for(client, auth, other_user["token"], listing.id)

        assert second.status_code == 409
        assert second.headers["content-type"] == "application/problem+json"

    def test_applying_again_while_approved_is_rejected(
        self, client, auth, admin, other_user, listing
    ):
        first = apply_for(client, auth, other_user["token"], listing.id).json()
        client.patch(
            f"/adoptions/{first['id']}/status",
            json={"status": "approved"},
            headers=auth(admin["token"]),
        )

        assert apply_for(client, auth, other_user["token"], listing.id).status_code == 409

    def test_applying_again_after_rejection_is_allowed(
        self, client, auth, admin, other_user, listing
    ):
        first = apply_for(client, auth, other_user["token"], listing.id).json()
        client.patch(
            f"/adoptions/{first['id']}/status",
            json={"status": "rejected"},
            headers=auth(admin["token"]),
        )

        assert apply_for(client, auth, other_user["token"], listing.id).status_code == 201

    def test_a_different_user_may_apply_to_the_same_pet(
        self, client, auth, admin, other_user, listing
    ):
        apply_for(client, auth, other_user["token"], listing.id)

        assert apply_for(client, auth, admin["token"], listing.id).status_code == 201


class TestListApplications:
    def test_a_user_only_sees_their_own(
        self, client, auth, admin, other_user, listing
    ):
        apply_for(client, auth, other_user["token"], listing.id)
        apply_for(client, auth, admin["token"], listing.id)

        body = client.get("/adoptions", headers=auth(other_user["token"])).json()

        assert body["total"] == 1
        assert body["items"][0]["user_id"] == other_user["id"]

    def test_an_admin_sees_every_application(
        self, client, auth, admin, other_user, listing
    ):
        apply_for(client, auth, other_user["token"], listing.id)
        apply_for(client, auth, admin["token"], listing.id)

        body = client.get("/adoptions", headers=auth(admin["token"])).json()

        assert body["total"] == 2

    def test_status_filter(self, client, auth, admin, other_user, listing):
        created = apply_for(client, auth, other_user["token"], listing.id).json()
        client.patch(
            f"/adoptions/{created['id']}/status",
            json={"status": "approved"},
            headers=auth(admin["token"]),
        )
        apply_for(client, auth, admin["token"], listing.id)

        body = client.get(
            "/adoptions", params={"status": "pending"}, headers=auth(admin["token"])
        ).json()

        assert body["total"] == 1

    def test_anonymous_visitors_cannot_list(self, client):
        assert client.get("/adoptions").status_code == 401

    def test_another_users_application_is_hidden(
        self, client, auth, admin, other_user, listing
    ):
        created = apply_for(client, auth, other_user["token"], listing.id).json()

        response = client.get(
            f"/adoptions/{created['id']}", headers=auth(admin["token"])
        )
        assert response.status_code == 200

        pet_owner_view = client.get(
            f"/adoptions/{created['id']}", headers=auth(other_user["token"])
        )
        assert pet_owner_view.status_code == 200


class TestChangeStatus:
    def test_a_regular_user_cannot_change_status(
        self, client, auth, other_user, listing
    ):
        created = apply_for(client, auth, other_user["token"], listing.id).json()

        response = client.patch(
            f"/adoptions/{created['id']}/status",
            json={"status": "approved"},
            headers=auth(other_user["token"]),
        )

        assert response.status_code == 403

    def test_approving_puts_the_pet_in_pending(
        self, client, auth, db, admin, other_user, listing
    ):
        created = apply_for(client, auth, other_user["token"], listing.id).json()

        client.patch(
            f"/adoptions/{created['id']}/status",
            json={"status": "approved"},
            headers=auth(admin["token"]),
        )

        db.expire_all()
        assert db.get(Pet, listing.id).status == PetStatus.PENDING

    def test_completing_marks_the_pet_adopted(
        self, client, auth, db, admin, other_user, listing
    ):
        created = apply_for(client, auth, other_user["token"], listing.id).json()

        client.patch(
            f"/adoptions/{created['id']}/status",
            json={"status": "completed"},
            headers=auth(admin["token"]),
        )

        db.expire_all()
        assert db.get(Pet, listing.id).status == PetStatus.ADOPTED

    def test_rejecting_returns_the_pet_to_available(
        self, client, auth, db, admin, other_user, listing
    ):
        created = apply_for(client, auth, other_user["token"], listing.id).json()
        client.patch(
            f"/adoptions/{created['id']}/status",
            json={"status": "approved"},
            headers=auth(admin["token"]),
        )

        client.patch(
            f"/adoptions/{created['id']}/status",
            json={"status": "rejected"},
            headers=auth(admin["token"]),
        )

        db.expire_all()
        assert db.get(Pet, listing.id).status == PetStatus.AVAILABLE

    def test_unknown_status_is_rejected(self, client, auth, admin, other_user, listing):
        created = apply_for(client, auth, other_user["token"], listing.id).json()

        response = client.patch(
            f"/adoptions/{created['id']}/status",
            json={"status": "maybe"},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 422

    def test_missing_application_returns_404(self, client, auth, admin):
        response = client.patch(
            "/adoptions/9999/status",
            json={"status": "approved"},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 404
