from decimal import Decimal

Age = Decimal | int | float


def _to_decimal(age: Age) -> Decimal:
    return age if isinstance(age, Decimal) else Decimal(str(age))


def _months(age: Decimal) -> int:
    return max(1, round(age * 12))


def _trim(age: Decimal) -> str:
    text = f"{age:f}"
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return text


def format_age(age: Age) -> str:
    value = _to_decimal(age)
    if value < 1:
        months = _months(value)
        return f"approximately {months} month{'' if months == 1 else 's'}"
    years = _trim(value)
    return f"{years} year{'' if years == '1' else 's'}"
