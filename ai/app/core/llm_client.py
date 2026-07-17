from anthropic import Anthropic, APIConnectionError, InternalServerError, RateLimitError
from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_exponential

from .config import settings

MODEL = "claude-haiku-4-5"

client = Anthropic(api_key=settings.anthropic_api_key)

@retry(
    retry=retry_if_exception_type((RateLimitError, InternalServerError, APIConnectionError)),
    wait=wait_exponential(min=settings.llm_wait_min, max=settings.llm_wait_max),
    stop=stop_after_attempt(settings.llm_max_attempts),
    reraise=True
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