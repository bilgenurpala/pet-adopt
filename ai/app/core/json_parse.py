import json

from fastapi import HTTPException

INVALID_OUTPUT = HTTPException(status_code=502, detail="AI returned invalid output")


def extract_json_object(raw: str) -> dict:
    start = raw.find("{")
    end = raw.rfind("}")
    if start == -1 or end == -1 or end < start:
        raise INVALID_OUTPUT

    try:
        data = json.loads(raw[start : end + 1])
    except json.JSONDecodeError:
        raise INVALID_OUTPUT

    if not isinstance(data, dict):
        raise INVALID_OUTPUT

    return data
