from __future__ import annotations

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import RedirectResponse

from utils.discord import get_user_roles, get_user_profile
from utils.roles import resolve_user_flags
from urllib.parse import urlencode
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
from jose import jwt, JWTError
import os
import time

SECRET_KEY = os.getenv("AUTH_SECRET_KEY", "secret")
ALGORITHM = "HS256"
TOKEN_EXPIRE_SECONDS = int(os.getenv("TOKEN_EXPIRE_SECONDS", "3600"))

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

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


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
    except (JWTError, KeyError, ValueError):
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

    # Fetch Discord roles and resolve verification/admin flags using stored
    # OAuth token.
    discord_token = user.discord_token
    roles = get_user_roles(discord_token)
    admin_guild = os.getenv("ADMIN_SERVER_GUILD_ID")
    if admin_guild:
        relevant_roles = roles.get(admin_guild, [])
    else:
        relevant_roles = [r for rs in roles.values() for r in rs]

    flags = resolve_user_flags(relevant_roles)

    profile = get_user_profile(discord_token)

    # Attach resolved information to the user object for downstream handlers
    user.roles = roles
    user.isAdmin = flags["isAdmin"]
    user.isVerified = flags["isVerified"]
    user.verificationType = flags["verificationType"]
    user.discord_id = profile["id"]
    user.discord_username = profile["username"]
    user.avatar = profile["avatar"]

    return user


app = FastAPI()


class _SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add basic security headers to all responses."""

    async def dispatch(self, request, call_next):  # type: ignore[override]
        resp = await call_next(request)
        resp.headers.setdefault("X-Content-Type-Options", "nosniff")
        resp.headers.setdefault("Access-Control-Allow-Origin", "*")
        return resp


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(_SecurityHeadersMiddleware)


@app.get("/health")
def health() -> dict[str, str]:
    """Return service health status."""
    return {"status": "ok"}


@app.post("/api/register")
def register(data: dict, db: Session = Depends(get_db)) -> dict[str, str]:
    """Create a new user and return an authentication token."""
    username = data["username"]
    password = data["password"]
    discord_token = data.get("discord_token")
    if db.query(User).filter_by(username=username).first():
        raise HTTPException(status_code=400, detail="Username exists")
    user = User(
        username=username,
        password_hash=pwd_context.hash(password),
        discord_token=discord_token,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"token": create_token(user)}


@app.post("/api/login")
def login(data: dict, db: Session = Depends(get_db)) -> dict[str, str]:
    """Authenticate a user and return a JWT."""
    username = data["username"]
    password = data["password"]
    discord_token = data.get("discord_token")
    user = db.query(User).filter_by(username=username).first()
    if not user or not pwd_context.verify(password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid credentials")
    if discord_token is not None:
        user.discord_token = discord_token
        db.commit()
    return {"token": create_token(user)}


@app.get("/login/discord")
def discord_login() -> RedirectResponse:
    """Redirect the user to Discord's OAuth consent screen."""
    params = {
        "client_id": os.getenv("DISCORD_CLIENT_ID"),
        "response_type": "code",
        "redirect_uri": os.getenv(
            "DISCORD_REDIRECT_URI",
            "http://localhost:8002/login/discord/callback",
        ),
        "scope": "identify guilds guilds.members.read",
    }
    url = "https://discord.com/oauth2/authorize?" + urlencode(params)
    return RedirectResponse(url)


@app.get("/login/discord/callback")
def discord_callback(code: str, db: Session = Depends(get_db)) -> dict[str, str]:
    """Exchange the OAuth code for a token and return a JWT."""
    token_resp = httpx.post(
        "https://discord.com/api/oauth2/token",
        data={
            "client_id": os.getenv("DISCORD_CLIENT_ID"),
            "client_secret": os.getenv("DISCORD_CLIENT_SECRET"),
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": os.getenv(
                "DISCORD_REDIRECT_URI",
                "http://localhost:8002/login/discord/callback",
            ),
        },
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    token_resp.raise_for_status()
    access_token = token_resp.json()["access_token"]

    profile = get_user_profile(access_token)
    username = profile["id"]
    user = db.query(User).filter_by(username=username).first()
    if not user:
        user = User(
            username=username,
            password_hash=pwd_context.hash(""),
            discord_token=access_token,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        user.discord_token = access_token
        db.commit()
    return {"token": create_token(user)}




@app.get("/api/user/onboarding-status")
def onboarding_status(current_user: User = Depends(get_current_user)) -> dict[str, str]:
    """Return the user's onboarding progress."""
    status_str = "complete" if current_user.contributions else "pending"
    return {"status": status_str}


@app.get("/api/user/level")
def user_level(current_user: User = Depends(get_current_user)) -> dict[str, int]:
    """Calculate the user's level from accumulated XP."""
    xp_total = sum(evt.xp for evt in current_user.events)
    level = xp_total // 100 + 1
    return {"level": level}


@app.get("/api/user/contributions")
def user_contributions(
    current_user: User = Depends(get_current_user),
) -> dict[str, list[str]]:
    """List the user's recorded contributions."""
    return {
        "contributions": [c.description for c in current_user.contributions]
    }


@app.post("/api/user/contributions")
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


@app.post("/api/user/promote")
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
    target.is_admin = True
    db.commit()
    return {"promoted": target.username}


def create_app() -> FastAPI:
    if os.getenv("INIT_DB_ON_STARTUP"):
        init_db()
    from routes.user import router as user_router
    app.include_router(user_router)
    return app


def main() -> None:
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8002)

