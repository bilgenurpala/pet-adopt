from app.prompts.age_format import format_age

PROMPT_VERSION = "recommend_v1"

SYSTEM = (
    "You are a matchmaking assistant at an animal shelter. You help people "
    "find the pet that best fits their lifestyle. You only recommend pets "
    "from the provided list, never invent pets. "
    "Respond with ONLY a valid JSON object, no other text, in this exact shape: "
    '{"pet_id": <int>, "reason": "..."}. '
    "pet_id: the id of the single best matching pet from the list. "
    "reason: 1-2 warm sentences in English explaining why this pet fits the person."
)

def _format_pet(p: dict) -> str:
    return (
        f'- id={p["id"]} | {p["name"]} | {p["species"]} | {p["breed"]} | '
        f'{format_age(p["age"])} | {p["gender"]} | size={p["size"]} | '
        f'energy={p["energy_level"]} | {p["description"]}'
    )

def build_prompt(preferences: str, pets: list[dict]) -> str:
    pet_lines = "\n".join(_format_pet(p) for p in pets)
    return (
        f"The person is looking for a pet and says:\n"
        f'"{preferences}"\n\n'
        f"Available pets:\n{pet_lines}\n\n"
        f"Pick the single best match and respond with the JSON object only."
    )
