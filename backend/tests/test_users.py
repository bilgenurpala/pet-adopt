from app.core.security import verify_password
from app.models.enums import Role
from app.models.user import User


class TestGetMe:
    def test_returns_the_logged_in_user(self, client, auth, user_token, registered_user):
        response = client.get("/users/me", headers=auth(user_token))

        assert response.status_code == 200
        assert response.json()["id"] == registered_user["id"]
        assert response.json()["role"] == Role.USER.value

    def test_requires_authentication(self, client):
        assert client.get("/users/me").status_code == 401

    def test_never_returns_the_password(self, client, auth, user_token):
        body = client.get("/users/me", headers=auth(user_token)).json()

        assert "password" not in body
        assert "password_hash" not in body

    def test_an_admin_sees_their_own_role(self, client, auth, admin):
        response = client.get("/users/me", headers=auth(admin["token"]))

        assert response.json()["role"] == Role.ADMIN.value


class TestListUsers:
    def test_admin_can_list(self, client, auth, admin, registered_user):
        response = client.get("/users", headers=auth(admin["token"]))

        assert response.status_code == 200
        assert response.json()["total"] == 2

    def test_regular_user_is_forbidden(self, client, auth, user_token):
        assert client.get("/users", headers=auth(user_token)).status_code == 403

    def test_anonymous_visitors_are_rejected(self, client):
        assert client.get("/users").status_code == 401

    def test_admin_can_read_a_single_user(
        self, client, auth, admin, registered_user
    ):
        response = client.get(
            f"/users/{registered_user['id']}", headers=auth(admin["token"])
        )

        assert response.status_code == 200
        assert response.json()["id"] == registered_user["id"]

    def test_missing_user_returns_404(self, client, auth, admin):
        response = client.get("/users/9999", headers=auth(admin["token"]))

        assert response.status_code == 404
        assert response.headers["content-type"] == "application/problem+json"


class TestCreateUser:
    def test_admin_can_create(self, client, auth, admin):
        response = client.post(
            "/users",
            json={
                "username": "yeni",
                "email": "yeni@example.com",
                "full_name": "Yeni Kullanici",
                "password": "createdbyadmin1",
            },
            headers=auth(admin["token"]),
        )

        assert response.status_code == 201
        assert response.json()["role"] == Role.USER.value

    def test_the_password_is_stored_as_a_hash(self, client, auth, db, admin):
        client.post(
            "/users",
            json={
                "username": "yeni",
                "email": "yeni@example.com",
                "full_name": "Yeni Kullanici",
                "password": "createdbyadmin1",
            },
            headers=auth(admin["token"]),
        )

        user = db.query(User).filter(User.email == "yeni@example.com").one()
        assert user.password_hash != "createdbyadmin1"
        assert verify_password("createdbyadmin1", user.password_hash)

    def test_duplicate_email_is_rejected(
        self, client, auth, admin, registered_user, user_payload
    ):
        response = client.post(
            "/users",
            json={**user_payload, "username": "different"},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 409

    def test_regular_user_is_forbidden(self, client, auth, user_token):
        response = client.post(
            "/users",
            json={
                "username": "yeni",
                "email": "yeni@example.com",
                "full_name": "Yeni Kullanici",
                "password": "createdbyadmin1",
            },
            headers=auth(user_token),
        )

        assert response.status_code == 403


class TestUpdateUser:
    def test_admin_can_update_a_user(self, client, auth, admin, registered_user):
        response = client.patch(
            f"/users/{registered_user['id']}",
            json={"full_name": "Yeni Isim"},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 200
        assert response.json()["full_name"] == "Yeni Isim"

    def test_updating_the_password_stores_a_new_hash(
        self, client, auth, db, admin, registered_user
    ):
        client.patch(
            f"/users/{registered_user['id']}",
            json={"password": "brandnewpassword"},
            headers=auth(admin["token"]),
        )

        user = db.get(User, registered_user["id"])
        assert verify_password("brandnewpassword", user.password_hash)

    def test_the_new_password_works_for_login(
        self, client, auth, admin, registered_user, user_payload
    ):
        client.patch(
            f"/users/{registered_user['id']}",
            json={"password": "brandnewpassword"},
            headers=auth(admin["token"]),
        )

        response = client.post(
            "/auth/login",
            json={"email": user_payload["email"], "password": "brandnewpassword"},
        )

        assert response.status_code == 200

    def test_taking_another_users_email_is_rejected(
        self, client, auth, admin, registered_user
    ):
        response = client.patch(
            f"/users/{registered_user['id']}",
            json={"email": "admin@example.com"},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 409

    def test_keeping_its_own_email_is_allowed(
        self, client, auth, admin, registered_user, user_payload
    ):
        response = client.patch(
            f"/users/{registered_user['id']}",
            json={"email": user_payload["email"]},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 200

    def test_regular_user_is_forbidden(
        self, client, auth, user_token, registered_user
    ):
        response = client.patch(
            f"/users/{registered_user['id']}",
            json={"full_name": "Hack"},
            headers=auth(user_token),
        )

        assert response.status_code == 403


class TestChangeRole:
    def test_admin_can_promote_a_user(self, client, auth, admin, registered_user):
        response = client.patch(
            f"/users/{registered_user['id']}/role",
            json={"role": "admin"},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 200
        assert response.json()["role"] == Role.ADMIN.value

    def test_a_promoted_user_gains_admin_powers_immediately(
        self, client, auth, admin, user_token, registered_user
    ):
        assert client.get("/users", headers=auth(user_token)).status_code == 403

        client.patch(
            f"/users/{registered_user['id']}/role",
            json={"role": "admin"},
            headers=auth(admin["token"]),
        )

        assert client.get("/users", headers=auth(user_token)).status_code == 200

    def test_admin_can_demote_a_user(self, client, auth, admin, registered_user):
        client.patch(
            f"/users/{registered_user['id']}/role",
            json={"role": "admin"},
            headers=auth(admin["token"]),
        )

        response = client.patch(
            f"/users/{registered_user['id']}/role",
            json={"role": "user"},
            headers=auth(admin["token"]),
        )

        assert response.json()["role"] == Role.USER.value

    def test_regular_user_cannot_promote_themselves(
        self, client, auth, user_token, registered_user
    ):
        response = client.patch(
            f"/users/{registered_user['id']}/role",
            json={"role": "admin"},
            headers=auth(user_token),
        )

        assert response.status_code == 403

    def test_unknown_role_is_rejected(self, client, auth, admin, registered_user):
        response = client.patch(
            f"/users/{registered_user['id']}/role",
            json={"role": "superadmin"},
            headers=auth(admin["token"]),
        )

        assert response.status_code == 422


class TestDeleteUser:
    def test_admin_can_delete_a_user_without_records(
        self, client, auth, admin, registered_user
    ):
        response = client.delete(
            f"/users/{registered_user['id']}", headers=auth(admin["token"])
        )

        assert response.status_code == 204

    def test_a_user_with_listings_cannot_be_deleted(
        self, client, auth, admin, registered_user, make_pet
    ):
        make_pet(registered_user["id"])

        response = client.delete(
            f"/users/{registered_user['id']}", headers=auth(admin["token"])
        )

        assert response.status_code == 409
        assert "1 listing" in response.json()["detail"]

    def test_a_user_with_applications_cannot_be_deleted(
        self, client, auth, admin, other_user, registered_user, make_pet
    ):
        pet = make_pet(registered_user["id"], is_approved=True)
        client.post(
            "/adoptions",
            json={"pet_id": pet.id},
            headers=auth(other_user["token"]),
        )

        response = client.delete(
            f"/users/{other_user['id']}", headers=auth(admin["token"])
        )

        assert response.status_code == 409

    def test_regular_user_is_forbidden(
        self, client, auth, user_token, registered_user
    ):
        response = client.delete(
            f"/users/{registered_user['id']}", headers=auth(user_token)
        )

        assert response.status_code == 403
