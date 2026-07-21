from decimal import Decimal

import pytest

from app.prompts.fee_format import format_fee


@pytest.mark.parametrize(
    "fee, expected",
    [
        (None, "adoption fee not set"),
        (Decimal("0.00"), "no adoption fee"),
        (0, "no adoption fee"),
        (Decimal("500.00"), "adoption fee 500"),
        (Decimal("249.50"), "adoption fee 249.5"),
        (750, "adoption fee 750"),
    ],
)
def test_format_fee(fee, expected):
    assert format_fee(fee) == expected


def test_fee_reaches_the_assistant_prompt(client, fake_llm, fake_pets):
    from tests.test_assistant import post

    post(client, [{"role": "user", "content": "I want a cheap calm cat"}])

    prompt = fake_llm["calls"]["compose"][0]
    assert "no adoption fee" in prompt
    assert "adoption fee 500" in prompt
