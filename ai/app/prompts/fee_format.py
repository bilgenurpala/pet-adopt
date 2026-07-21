from decimal import Decimal

Fee = Decimal | int | float | None


def _trim(value: Decimal) -> str:
    text = f"{value:f}"
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return text


def format_fee(fee: Fee) -> str:
    if fee is None:
        return "adoption fee not set"

    value = fee if isinstance(fee, Decimal) else Decimal(str(fee))
    if value == 0:
        return "no adoption fee"

    return f"adoption fee {_trim(value)}"
