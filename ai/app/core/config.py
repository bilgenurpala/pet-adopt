from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    anthropic_api_key: str
    llm_max_attempts: int = 3
    llm_wait_min: float = 1.0
    llm_wait_max: float = 10.0

    model_config = SettingsConfigDict(env_file=".env")

settings = Settings()