"""Human-readable age formatting for prompts.

Since the age contract changed to decimal(3,1), values below 1 are now
possible (0.5 = ~6 months). Writing "0.5 years old" into a prompt reads
awkwardly and the model tends to echo it, so anything under a year is
expressed in months instead.
"""

from decimal import Decimal

Age = Decimal | int | float


def _to_decimal(age: Age) -> Decimal:
    return age if isinstance(age, Decimal) else Decimal(str(age))


def _months(age: Decimal) -> int:
    # 0.5 -> 6, 0.3 -> 4. Never report "0 months" for a nonzero age.
    return max(1, round(age * 12))


def _trim(age: Decimal) -> str:
    """Decimal("3.0") -> "3", Decimal("2.5") -> "2.5"."""
    text = f"{age:f}"
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return text


def format_age_en(age: Age) -> str:
    value = _to_decimal(age)
    if value < 1:
        months = _months(value)
        return f"approximately {months} month{'' if months == 1 else 's'}"
    years = _trim(value)
    return f"{years} year{'' if years == '1' else 's'}"


def format_age_tr(age: Age) -> str:
    value = _to_decimal(age)
    if value < 1:
        return f"yaklasik {_months(value)} aylik"
    return f"{_trim(value)} yas"
