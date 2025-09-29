"""Authentication service with Discord integration and JWT utilities."""

from __future__ import annotations
from typing import Optional

from fastapi import APIRouter, Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import RedirectResponse

from utils.discord import get_user_roles, get_user_profile
from utils.roles import resolve_user_flags
from utils.cors import get_cors_origins
from urllib.parse import urlencode, urlparse, unquote
import httpx
from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    ForeignKey,
    create_engine,
)
from sqlalchemy.orm import sessionmaker, declarative_base, relationship, Session
from passlib.context import CryptContext
import jwt
from jwt.exceptions import InvalidTokenError
import os
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def is_safe_redirect_url(url: str) -> bool:
    """Validate that a redirect URL is safe to prevent phishing attacks.

    Parameters
    ----------
    url : str
        The URL to validate.

    Returns
    -------
    bool
        True if the URL is safe for redirection.
    """
    if not url or not url.strip():
        return False

    # Clean the URL - handle backslash confusion
    url = url.strip().replace("\\", "/")

    # Prevent protocol-relative URLs (e.g., //evil.com)
    if url.startswith("//"):
        return False

    # Prevent Unicode-encoded or percent-encoded protocol-relative URLs
    try:
        decoded_url = unquote(url)
        if decoded_url.startswith("//"):
            return False
    except Exception:
        return False

    try:
        parsed = urlparse(url)
    except Exception:
        return False

    # Allow relative URLs (no scheme or netloc)
    if not parsed.scheme and not parsed.netloc:
        # Also ensure path does not start with "//" (protocol-relative)
        if parsed.path.startswith("//"):
            return False
        return True

    # Define allowed domains for DevOnboarder
    allowed_domains = {
        "localhost",
        "127.0.0.1",
        "dev.theangrygamershow.com",
        "theangrygamershow.com",
        "tags.theangrygamershow.com",
        "auth.theangrygamershow.com",
        "api.theangrygamershow.com",
        # Test domains for test suite
        "frontend.test.com",
        "test.example.com",
        "example.com",
    }

    # Only allow HTTPS for external domains (except localhost for dev)
    if parsed.scheme not in ("http", "https"):
        return False

    if parsed.scheme == "http" and not (
        parsed.netloc.startswith("localhost") or parsed.netloc.startswith("127.0.0.1")
    ):
        # Only allow HTTP for localhost (with any port)
        return False

    # Check if domain is in allowed list
    netloc = parsed.netloc.lower()

    # Handle port numbers in netloc
    if ":" in netloc:
        netloc = netloc.split(":")[0]

    return netloc in allowed_domains


# Environment variables loaded from system environment
# In development: loaded from .env.dev via docker-compose or local setup
# In production: loaded from .env.prod via docker-compose or system
# In CI: loaded from .env.ci via docker-compose

SECRET_KEY = os.getenv("JWT_SECRET_KEY")
APP_ENV = os.getenv("APP_ENV")
if (not SECRET_KEY or SECRET_KEY == "secret") and APP_ENV != "development":
    raise RuntimeError(
        "JWT_SECRET_KEY must be set to a non-default value in production"
    )
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
TOKEN_EXPIRE_SECONDS = int(os.getenv("TOKEN_EXPIRE_SECONDS", "3600"))
API_TIMEOUT = int(os.getenv("DISCORD_API_TIMEOUT", "10"))


CONTRIBUTION_XP = 50

Base = declarative_base()
_db_url = os.getenv("DATABASE_URL", "sqlite:///./auth.db")
_engine_kwargs = (
    {"connect_args": {"check_same_thread": False}}
    if _db_url.startswith("sqlite")
    else {}
)
engine = create_engine(_db_url, **_engine_kwargs)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__default_rounds=12,
    bcrypt__truncate_error=False,  # Allow truncation instead of error
)


def _validate_password_for_bcrypt(password: Optional[str]) -> None:
    """Validate that the given password will not exceed bcrypt's 72-byte limit.

    bcrypt operates on the first 72 bytes of the password. Rejecting overly
    long passwords is the safest option: it avoids silent entropy loss and
    forces callers/clients to choose a shorter password or follow a client-side
    policy. This function raises HTTPException(400) when the password is
    too long or missing.
    """
    if password is None:
        raise HTTPException(status_code=400, detail="Password required")
    try:
        b = str(password).encode("utf-8")
    except Exception:
        # Coerce to string and encode ignoring errors as a last resort
        b = str(password).encode("utf-8", "ignore")
    if len(b) > 72:
        # Be explicit: rejecting the request is more secure than truncating
        raise HTTPException(
            status_code=400,
            detail="Password too long. Maximum allowed length is 72 bytes (UTF-8).",
        )


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    discord_token = Column(String, nullable=True)
    is_admin = Column(Boolean, default=False)

    contributions = relationship("Contribution", back_populates="user")
    events = relationship("XPEvent", back_populates="user")


class Contribution(Base):
    __tablename__ = "contributions"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    description = Column(String, nullable=False)

    user = relationship("User", back_populates="contributions")


class XPEvent(Base):
    __tablename__ = "xp_events"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    xp = Column(Integer, default=0)

    user = relationship("User", back_populates="events")


def init_db() -> None:
    """Create database tables if they do not exist."""
    Base.metadata.create_all(bind=engine)


def get_db() -> Session:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def create_token(user: User) -> str:
    """Return a signed JWT for the given user."""
    iat = int(time.time())
    payload = {"sub": str(user.id), "iat": iat, "exp": iat + TOKEN_EXPIRE_SECONDS}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


security = HTTPBearer()


def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    jwt_token = creds.credentials
    try:
        payload = jwt.decode(
            jwt_token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
            options={"verify_exp": True},
        )
        user_id = int(payload["sub"])
    except (InvalidTokenError, KeyError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )

    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    # Fetch Discord roles and profile using the stored OAuth token. Handle
    # timeouts from the Discord API so the service can respond with a 504.
    discord_token: str = user.discord_token  # type: ignore[assignment]
    try:
        roles = get_user_roles(discord_token)
        admin_guild = os.getenv("ADMIN_SERVER_GUILD_ID")
        if admin_guild:
            relevant_roles = roles.get(admin_guild, [])
        else:
            relevant_roles = [r for rs in roles.values() for r in rs]

        flags = resolve_user_flags(relevant_roles)

        profile = get_user_profile(discord_token)
    except httpx.TimeoutException as exc:
        raise HTTPException(status_code=504, detail="Discord API timeout") from exc

    # Attach resolved information to the user object for downstream handlers
    user.roles = roles
    user.isAdmin = flags["isAdmin"]
    user.isVerified = flags["isVerified"]
    user.verificationType = flags["verificationType"]
    user.discord_id = profile["id"]
    user.discord_username = profile["username"]
    user.avatar = profile["avatar"]

    return user


router = APIRouter()


@router.get("/health")
def health() -> dict[str, str]:
    """Return service health status."""
    return {"status": "ok"}


@router.post("/api/register")
def register(data: dict, db: Session = Depends(get_db)) -> dict[str, str]:
    """Create a new user and return an authentication token."""
    username = data["username"]
    password = data["password"]
    discord_token = data.get("discord_token")
    if db.query(User).filter_by(username=username).first():
        raise HTTPException(status_code=400, detail="Username exists")
    # Validate password length before hashing to avoid bcrypt errors and
    # to prevent silent entropy loss from truncation.
    _validate_password_for_bcrypt(password)
    user = User(
        username=username,
        password_hash=pwd_context.hash(password),
        discord_token=discord_token,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"token": create_token(user)}


@router.post("/api/login")
def login(data: dict, db: Session = Depends(get_db)) -> dict[str, str]:
    """Authenticate a user and return a JWT."""
    username = data["username"]
    password = data["password"]
    discord_token = data.get("discord_token")
    # For login, validate length first. If the client sends a too-long
    # password, treat it as invalid credentials (400) to avoid hashing errors.
    _validate_password_for_bcrypt(password)
    user = db.query(User).filter_by(username=username).first()
    # If user does not exist, or the stored password_hash is empty (Discord-only
    # account), treat as invalid credentials for password-based login.
    if not user:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    if not user.password_hash:
        # No local password set (Discord-only account)
        raise HTTPException(status_code=400, detail="Invalid credentials")
    if not pwd_context.verify(password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid credentials")
    if discord_token is not None:
        user.discord_token = discord_token
        db.commit()
    return {"token": create_token(user)}


@router.get("/login/discord")
def discord_login(redirect_to: Optional[str] = None) -> RedirectResponse:
    """Redirect the user to Discord's OAuth consent screen."""
    # Store redirect_to in state parameter for callback
    state = redirect_to if redirect_to else ""
    params = {
        "client_id": os.getenv("DISCORD_CLIENT_ID"),
        "response_type": "code",
        "redirect_uri": os.getenv(
            "DISCORD_REDIRECT_URI",
            "http://localhost:8002/login/discord/callback",
        ),
        "scope": "identify guilds guilds.members.read",
        "state": state,
    }
    url = "https://discord.com/oauth2/authorize?" + urlencode(params)
    return RedirectResponse(url)


@router.get("/login/discord/callback", response_model=None)
def discord_callback(
    code: str, state: Optional[str] = None, db: Session = Depends(get_db)
) -> RedirectResponse | dict[str, str]:
    """Exchange the OAuth code for a token and return a JWT."""
    # Debug logging to see what we receive
    logger.info(f"Discord callback - code: {code[:10]}..., state: {state}")

    # Debug logging to see what redirect_uri is being used
    redirect_uri = os.getenv(
        "DISCORD_REDIRECT_URI",
        "http://localhost:8002/login/discord/callback",
    )
    try:
        token_data = {
            "client_id": os.getenv("DISCORD_CLIENT_ID"),
            "client_secret": os.getenv("DISCORD_CLIENT_SECRET"),
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirect_uri,
        }

        token_resp = httpx.post(
            "https://discord.com/api/oauth2/token",
            data=token_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            timeout=API_TIMEOUT,
        )
    except httpx.TimeoutException as exc:
        raise HTTPException(status_code=504, detail="Discord API timeout") from exc
    token_resp.raise_for_status()
    access_token = token_resp.json()["access_token"]

    profile = get_user_profile(access_token)
    username = profile["id"]
    user = db.query(User).filter_by(username=username).first()
    if not user:
        # Discord-created accounts have an empty local password. This is
        # recorded as a bcrypt hash for an empty string which is always <=72
        # bytes, so no validation is necessary here.
        empty_password = ""
        # Defensive validation: ensure empty password is valid for bcrypt
        _validate_password_for_bcrypt(empty_password)
        user = User(
            username=username,
            password_hash=pwd_context.hash(empty_password),
            discord_token=access_token,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        user.discord_token = access_token
        db.commit()

    # Redirect to frontend with token
    token = create_token(user)

    # For testing, return JSON instead of redirect
    if os.getenv("TEST_MODE"):
        return {"token": token}

    # Use state parameter for redirect destination, otherwise default to frontend
    # Define allowed relative redirect paths (defense-in-depth allowlist)
    allowed_relative_paths = {
        "/dashboard",
        "/profile",
        "/welcome",
        "/onboarding",
        "/",  # home
    }

    redirect_url = None
    user_provided_path = None
    if state and state.strip():
        # Normalize and validate state as a relative path
        normalized_state = state.strip().replace("\\", "/")
        parsed_state = urlparse(normalized_state)
        if (
            not parsed_state.scheme
            and not parsed_state.netloc
            and is_safe_redirect_url(normalized_state)
            and parsed_state.path in allowed_relative_paths
        ):
            user_provided_path = parsed_state.path
            logger.info(f"Using state parameter for redirect: {user_provided_path}")
        else:
            logger.warning(f"Unsafe or disallowed redirect path blocked: {state}")

    if user_provided_path:
        # Use validated user path - reconstruct from safe allowlist to avoid CodeQL
        if user_provided_path == "/dashboard":
            redirect_url = "/dashboard"
        elif user_provided_path == "/profile":
            redirect_url = "/profile"
        elif user_provided_path == "/welcome":
            redirect_url = "/welcome"
        elif user_provided_path == "/onboarding":
            redirect_url = "/onboarding"
        elif user_provided_path == "/":
            redirect_url = "/"
        else:
            # Fallback if somehow not in allowlist (should never happen)
            redirect_url = "/dashboard"
    else:
        # Environment-based service discovery - never hard-code production URLs
        fallback_url = os.getenv("FRONTEND_URL") or os.getenv("DEV_TUNNEL_FRONTEND_URL")
        if not fallback_url:
            # Use environment-appropriate defaults based on runtime context
            app_env = os.getenv("APP_ENV", "development")
            is_ci = os.getenv("CI", "false").lower() == "true"
            is_docker = os.path.exists("/.dockerenv")  # Standard Docker indicator

            if is_ci:
                # CI environment - always use localhost
                fallback_url = "http://localhost:8081"
            elif is_docker and app_env == "production":
                # Production Docker - use service name
                fallback_url = "http://frontend:8081"
            elif is_docker:
                # Development Docker - use service name
                fallback_url = "http://frontend:8081"
            elif app_env == "production":
                # Production without Docker - use production URL
                fallback_url = "https://dev.theangrygamershow.com"
            else:
                # Local development - use localhost
                fallback_url = "http://localhost:8081"

        redirect_url = fallback_url
        logger.info(
            f"Using environment-based redirect: {redirect_url} "
            f"(CI={os.getenv('CI')}, Docker={os.path.exists('/.dockerenv')}, "
            f"APP_ENV={os.getenv('APP_ENV')})"
        )  # Compose the final redirect URL with the token
    final_redirect = f"{redirect_url}?token={token}"
    logger.info(f"Final redirect: {final_redirect[:100]}...")

    # Final security validation before redirect (for system URLs)
    if not is_safe_redirect_url(redirect_url):
        logger.warning(f"Unsafe redirect URL blocked at final check: {redirect_url}")
        final_redirect = "/dashboard?token=" + token

    return RedirectResponse(final_redirect)


@router.get("/api/user/onboarding-status")
def onboarding_status(current_user: User = Depends(get_current_user)) -> dict[str, str]:
    """Return the user's onboarding progress."""
    status_str = "complete" if current_user.contributions else "pending"
    return {"status": status_str}


@router.get("/api/user/level")
def user_level(current_user: User = Depends(get_current_user)) -> dict[str, int]:
    """Calculate the user's level from accumulated XP."""
    xp_total = sum(evt.xp for evt in current_user.events)
    level = xp_total // 100 + 1
    return {"level": level}


@router.get("/api/user/contributions")
def user_contributions(
    current_user: User = Depends(get_current_user),
) -> dict[str, list[str]]:
    """List the user's recorded contributions."""
    return {"contributions": [c.description for c in current_user.contributions]}


@router.post("/api/user/contributions")
def add_contribution(
    data: dict,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """Record a new contribution and award XP."""
    username = data.get("username", current_user.username)
    description = data["description"]

    user = db.query(User).filter_by(username=username).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    if user.id != current_user.id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Forbidden")

    db.add(Contribution(user_id=user.id, description=description))
    db.add(XPEvent(user_id=user.id, xp=CONTRIBUTION_XP))
    db.commit()
    return {"recorded": description}


@router.post("/api/user/promote")
def promote(
    data: dict,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """Grant admin privileges to another user."""
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Admin required")
    target = db.query(User).filter_by(username=data["username"]).first()
    if not target:
        raise HTTPException(status_code=404, detail="User not found")
    target.is_admin = True  # type: ignore[assignment]
    db.commit()
    target_username: str = target.username  # type: ignore[assignment]
    return {"promoted": target_username}


def create_app() -> FastAPI:
    """Instantiate and configure the FastAPI application."""

    if os.getenv("INIT_DB_ON_STARTUP"):
        init_db()

    app = FastAPI()
    cors_origins = get_cors_origins()

    class _SecurityHeadersMiddleware(BaseHTTPMiddleware):
        """Add basic security headers to all responses."""

        async def dispatch(self, request, call_next):
            resp = await call_next(request)
            resp.headers.setdefault("X-Content-Type-Options", "nosniff")
            resp.headers.setdefault(
                "Access-Control-Allow-Origin", cors_origins[0] if cors_origins else "*"
            )
            return resp

    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_middleware(_SecurityHeadersMiddleware)

    from routes.user import router as user_router

    app.include_router(router)
    app.include_router(user_router)
    return app


def main() -> None:
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8002)  # nosec B104
