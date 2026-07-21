from tests.conftest import PIXEL


def post_image(client, data, media_type="image/png"):
    return client.post(
        "/assistant",
        json={
            "messages": [
                {
                    "role": "user",
                    "content": "What is this?",
                    "image": {"media_type": media_type, "data": data},
                }
            ]
        },
    )


def test_plain_base64_is_accepted(client, fake_llm, fake_pets):
    assert post_image(client, PIXEL).status_code == 200


def test_data_url_prefix_is_stripped(client, fake_llm, fake_pets):
    response = post_image(client, f"data:image/png;base64,{PIXEL}")

    assert response.status_code == 200
    assert fake_llm["calls"]["vision"][0] == PIXEL


def test_whitespace_and_newlines_are_stripped(client, fake_llm, fake_pets):
    chunked = "\n".join([PIXEL[:20], PIXEL[20:40], PIXEL[40:]])

    response = post_image(client, chunked)

    assert response.status_code == 200
    assert fake_llm["calls"]["vision"][0] == PIXEL


def test_garbage_base64_is_rejected(client, fake_llm, fake_pets):
    response = post_image(client, "this is definitely not base64!!!")

    assert response.status_code == 422


def test_empty_image_data_is_rejected(client, fake_llm, fake_pets):
    response = post_image(client, "")

    assert response.status_code == 422


def test_unsupported_media_type_is_rejected(client, fake_llm, fake_pets):
    response = post_image(client, PIXEL, media_type="image/bmp")

    assert response.status_code == 422


def test_oversized_image_is_rejected(client, fake_llm, fake_pets):
    import base64

    oversized = base64.b64encode(b"x" * (5 * 1024 * 1024 + 10)).decode()

    response = post_image(client, oversized)

    assert response.status_code == 422


def test_provider_failure_becomes_502(client, fake_llm, fake_pets, monkeypatch):
    import httpx
    from anthropic import APIStatusError

    def boom(*args, **kwargs):
        raise APIStatusError(
            "bad request",
            response=httpx.Response(
                400, request=httpx.Request("POST", "https://api.anthropic.com")
            ),
            body=None,
        )

    monkeypatch.setattr("app.services.classify_service.ask_claude_vision", boom)

    response = post_image(client, PIXEL)

    assert response.status_code == 502
