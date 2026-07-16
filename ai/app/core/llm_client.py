from anthropic import Anthropic
from .config import settings
from anthropic import Anthropic, APIConnectionError, InternalServerError, RateLimitError
from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_exponential

MODEL = "claude-haiku-4-5"

client = Anthropic(api_key=settings.anthropic_api_key)

@retry(
    retry=retry_if_exception_type((RateLimitError, InternalServerError, APIConnectionError)),
    wait=wait_exponential(min=1, max=10),
    stop=stop_after_attempt(3),
)

def ask_claude(prompt: str, system: str | None = None, max_tokens: int = 1024) -> str:
    kwargs = {}
    if system: 
        kwargs["system"] = system

    message = client.messages.create(
        model=MODEL,
        max_tokens=max_tokens,
        messages=[{"role": "user", "content": prompt}],
        **kwargs,
    )
    return message.content[0].text