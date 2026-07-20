import pytest
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials

from app.core import security
from app.core.config import settings
from app.core.deps import get_current_user, get_current_user_optional, require_admin
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_access_token,
    decode_refresh_token,
)
from app.models.enums import Role
from app.models.user import User


def credentials(token):
    return HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)


class TestRegister:
    def test_registers_a_new_user(self, client, user_payload):
        response = client.post("/auth/register", json=user_payload)

        assert response.status_code == 201
        body = response.json()
        assert body["email"] == user_payload["email"]
        assert body["role"] == Role.USER.value

    def test_never_returns_the_password(self, client, user_payload):
        body = client.post("/auth/register", json=user_payload).json()

        assert "password" not in body
        assert "password_hash" not in body

    def test_stores_a_hash_not_the_plain_password(self, client, db, user_payload):
        client.post("/auth/register", json=user_payload)

        user = db.query(User).filter(User.email == user_payload["email"]).one()
        assert user.password_hash != user_payload["password"]
        assert security.verify_password(user_payload["password"], user.password_hash)

    def test_role_cannot_be_escalated_by_the_client(self, client, db, user_payload):
        client.post("/auth/register", json={**user_payload, "role": "admin"})

        user = db.query(User).filter(User.email == user_payload["email"]).one()
        assert user.role == Role.USER

    def test_duplicate_email_is_rejected(self, client, registered_user, user_payload):
        response = client.post(
            "/auth/register", json={**user_payload, "username": "different"}
        )

        assert response.status_code == 409
        assert response.headers["content-type"] == "application/problem+json"

    def test_duplicate_username_is_rejected(self, client, registered_user, user_payload):
        response = client.post(
            "/auth/register", json={**user_payload, "email": "other@example.com"}
        )

        assert response.status_code == 409

    @pytest.mark.parametrize(
        "password",
        ["short", "a" * 73],
        ids=["too_short", "over_bcrypt_limit"],
    )
    def test_password_length_is_validated(self, client, user_payload, password):
        response = client.post(
            "/auth/register", json={**user_payload, "password": password}
        )

        assert response.status_code == 422

    def test_invalid_email_is_rejected(self, client, user_payload):
        response = client.post(
            "/auth/register", json={**user_payload, "email": "not-an-email"}
        )

        assert response.status_code == 422

    @pytest.mark.parametrize(
        "missing", ["username", "email", "full_name", "password"]
    )
    def test_missing_fields_are_rejected(self, client, user_payload, missing):
        payload = {k: v for k, v in user_payload.items() if k != missing}

        assert client.post("/auth/register", json=payload).status_code == 422


class TestLogin:
    def test_valid_credentials_return_a_token(self, client, registered_user, user_payload):
        response = client.post(
            "/auth/login",
            json={"email": user_payload["email"], "password": user_payload["password"]},
        )

        assert response.status_code == 200
        assert response.json()["token_type"] == "bearer"
        assert decode_access_token(response.json()["access_token"]) == registered_user["id"]

    def test_wrong_password_is_rejected(self, client, registered_user, user_payload):
        response = client.post(
            "/auth/login",
            json={"email": user_payload["email"], "password": "wrong-password"},
        )

        assert response.status_code == 401

    def test_unknown_email_gives_the_same_message_as_a_wrong_password(
        self, client, registered_user, user_payload
    ):
        wrong_password = client.post(
            "/auth/login",
            json={"email": user_payload["email"], "password": "wrong-password"},
        )
        unknown_email = client.post(
            "/auth/login",
            json={"email": "nobody@example.com", "password": user_payload["password"]},
        )

        assert unknown_email.status_code == wrong_password.status_code
        assert unknown_email.json()["detail"] == wrong_password.json()["detail"]

    def test_malformed_body_is_rejected(self, client):
        assert client.post("/auth/login", json={"email": "a@b.com"}).status_code == 422


class TestRefresh:
    def test_login_returns_both_tokens(self, login_body, registered_user):
        assert decode_access_token(login_body["access_token"]) == registered_user["id"]
        assert decode_refresh_token(login_body["refresh_token"]) == registered_user["id"]

    def test_the_two_tokens_are_not_interchangeable(self, login_body):
        assert decode_refresh_token(login_body["access_token"]) is None
        assert decode_access_token(login_body["refresh_token"]) is None

    def test_valid_refresh_returns_a_working_access_token(
        self, client, db, registered_user, user_refresh_token
    ):
        response = client.post(
            "/auth/refresh", json={"refresh_token": user_refresh_token}
        )

        assert response.status_code == 200
        new_access = response.json()["access_token"]
        user = get_current_user(credentials=credentials(new_access), db=db)
        assert user.id == registered_user["id"]

    def test_refresh_rotates_the_refresh_token(self, client, user_refresh_token):
        body = client.post(
            "/auth/refresh", json={"refresh_token": user_refresh_token}
        ).json()

        assert body["refresh_token"] != user_refresh_token
        assert decode_refresh_token(body["refresh_token"]) is not None

    def test_access_token_cannot_be_used_to_refresh(self, client, user_token):
        response = client.post("/auth/refresh", json={"refresh_token": user_token})

        assert response.status_code == 401

    def test_refresh_token_cannot_be_used_as_an_access_token(
        self, db, user_refresh_token
    ):
        with pytest.raises(HTTPException) as exc:
            get_current_user(credentials=credentials(user_refresh_token), db=db)

        assert exc.value.status_code == 401

    def test_expired_refresh_token_is_rejected(
        self, client, registered_user, monkeypatch
    ):
        monkeypatch.setattr(settings, "refresh_token_expire_days", -1)
        expired = create_refresh_token(registered_user["id"])

        response = client.post("/auth/refresh", json={"refresh_token": expired})

        assert response.status_code == 401

    def test_refresh_token_of_a_deleted_user_is_rejected(
        self, client, db, registered_user, user_refresh_token
    ):
        db.query(User).filter(User.id == registered_user["id"]).delete()
        db.commit()

        response = client.post(
            "/auth/refresh", json={"refresh_token": user_refresh_token}
        )

        assert response.status_code == 401

    def test_garbage_token_is_rejected(self, client):
        response = client.post("/auth/refresh", json={"refresh_token": "not-a-token"})

        assert response.status_code == 401
        assert response.headers["content-type"] == "application/problem+json"

    def test_missing_field_is_rejected(self, client):
        assert client.post("/auth/refresh", json={}).status_code == 422


class TestGetCurrentUser:
    def test_valid_token_resolves_to_the_user(self, db, registered_user, user_token):
        user = get_current_user(credentials=credentials(user_token), db=db)

        assert user.id == registered_user["id"]

    def test_missing_credentials_are_rejected(self, db):
        with pytest.raises(HTTPException) as exc:
            get_current_user(credentials=None, db=db)

        assert exc.value.status_code == 401

    def test_tampered_token_is_rejected(self, db, user_token):
        tampered = user_token[:-2] + ("xy" if user_token[-2:] != "xy" else "za")

        with pytest.raises(HTTPException) as exc:
            get_current_user(credentials=credentials(tampered), db=db)

        assert exc.value.status_code == 401

    def test_token_signed_with_another_key_is_rejected(self, db, registered_user):
        import jwt

        forged = jwt.encode(
            {"sub": str(registered_user["id"])}, "attacker-key", algorithm="HS256"
        )

        with pytest.raises(HTTPException) as exc:
            get_current_user(credentials=credentials(forged), db=db)

        assert exc.value.status_code == 401

    def test_expired_token_is_rejected(self, db, registered_user, monkeypatch):
        monkeypatch.setattr(settings, "access_token_expire_minutes", -1)
        expired = create_access_token(registered_user["id"])

        assert decode_access_token(expired) is None

        with pytest.raises(HTTPException) as exc:
            get_current_user(credentials=credentials(expired), db=db)

        assert exc.value.status_code == 401

    def test_token_of_a_deleted_user_is_rejected(self, db, registered_user, user_token):
        db.query(User).filter(User.id == registered_user["id"]).delete()
        db.commit()

        with pytest.raises(HTTPException) as exc:
            get_current_user(credentials=credentials(user_token), db=db)

        assert exc.value.status_code == 401


class TestOptionalCurrentUser:
    def test_returns_none_without_credentials(self, db):
        assert get_current_user_optional(credentials=None, db=db) is None

    def test_returns_none_for_an_invalid_token(self, db):
        assert get_current_user_optional(credentials=credentials("nonsense"), db=db) is None

    def test_returns_the_user_for_a_valid_token(self, db, registered_user, user_token):
        user = get_current_user_optional(credentials=credentials(user_token), db=db)

        assert user is not None
        assert user.id == registered_user["id"]


class TestRequireAdmin:
    def test_regular_user_is_forbidden(self, db, registered_user, user_token):
        user = get_current_user(credentials=credentials(user_token), db=db)

        with pytest.raises(HTTPException) as exc:
            require_admin(current_user=user)

        assert exc.value.status_code == 403

    def test_admin_is_allowed(self, db, registered_user, user_token):
        user = get_current_user(credentials=credentials(user_token), db=db)
        user.role = Role.ADMIN
        db.commit()

        assert require_admin(current_user=user) is user

    def test_role_change_applies_to_an_already_issued_token(
        self, db, registered_user, user_token
    ):
        db.query(User).filter(User.id == registered_user["id"]).update(
            {"role": Role.ADMIN}
        )
        db.commit()

        user = get_current_user(credentials=credentials(user_token), db=db)

        assert require_admin(current_user=user) is user
