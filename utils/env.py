# PATCHED v0.1.47 utils/env.py — Remove default env placeholders

"""Load and validate required environment variables."""

from pydantic import Field, ValidationError
from pydantic_settings import BaseSettings, SettingsConfigDict
from dotenv import load_dotenv
from functools import lru_cache

load_dotenv(".env.development", override=False)


class Settings(BaseSettings):
    """Application environment settings."""

    DISCORD_CLIENT_ID: str
    DISCORD_CLIENT_SECRET: str
    DATABASE_URL: str
    REDIS_URL: str
    JWT_SECRET: str
    JWT_ALGORITHM: str = Field(default="HS256")
    JWT_EXPIRATION: int = Field(default=3600)
    OWNER_ROLE_ID: str
    ADMINISTRATOR_ROLE_ID: str
    VERIFIED_USER_ROLE_ID: str
    VERIFIED_MEMBER_ROLE_ID: str
    ALLOWED_ORIGINS: str
    OPENAI_API_KEY: str = Field(..., env="OPENAI_API_KEY")
    FASTAPI_SECRET_KEY: str

    model_config = SettingsConfigDict(
        env_file=".env.development",
        env_file_encoding="utf-8",
        secrets_dir="/run/secrets",
    )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return validated environment settings."""
    try:
        return Settings()
    except ValidationError as exc:
        # pragma: no cover - re-raise for startup failure
        raise RuntimeError(f"Invalid environment configuration: {exc}")
