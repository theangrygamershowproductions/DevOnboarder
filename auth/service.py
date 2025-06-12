# PATCHED v0.1.22 auth/service.py — FastAPI auth with JWT handling

"""Minimal authentication service using JWT bearer tokens."""

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from datetime import datetime, timedelta, UTC
import os
import uuid
import jwt
from dotenv import load_dotenv
from utils.env import get_settings
from utils.redis_client import get_redis_client

load_dotenv()

settings = get_settings()

JWT_SECRET = os.getenv("JWT_SECRET", "secret")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRATION = int(os.getenv("JWT_EXPIRATION", "3600"))

app = FastAPI(title="Auth Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[orig.strip() for orig in settings.ALLOWED_ORIGINS.split(",")],
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
    allow_credentials=True,
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


class Token(BaseModel):
    """OAuth2 access token response."""

    access_token: str
    token_type: str = "bearer"


class User(BaseModel):
    """Authenticated user payload."""

    id: str
    username: str
    is_admin: bool = False


# In-memory store for example purposes
USERS = {
    "demo": {
        "id": "1",
        "username": "demo",
        "password": "password",
        "is_admin": True,
    }
}

# Redis connection shared across handlers
redis_client = get_redis_client()


@app.post("/api/auth/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends()) -> Token:
    """Authenticate a user and return a JWT access token."""
    user = USERS.get(form_data.username)
    if not user or user.get("password") != form_data.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )
    exp = datetime.now(UTC) + timedelta(seconds=JWT_EXPIRATION)
    jti = uuid.uuid4().hex
    token = jwt.encode(
        {"sub": user["id"], "jti": jti, "exp": exp},
        JWT_SECRET,
        algorithm=JWT_ALGORITHM,
    )
    return Token(access_token=token)


def decode_token(token: str = Depends(oauth2_scheme)) -> User:
    """Decode a JWT token and return the associated user."""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
        )
    jti = payload.get("jti")
    if jti and redis_client.get(jti):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
        )
    user_id = payload.get("sub")
    for data in USERS.values():
        if data["id"] == user_id:
            return User(
                id=data["id"],
                username=data["username"],
                is_admin=data["is_admin"],
            )
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found"
    )


@app.get("/api/auth/user", response_model=User)
def get_user(current_user: User = Depends(decode_token)) -> User:
    """Return the current authenticated user."""
    return current_user


@app.post("/api/auth/logout")
def logout(token: str = Depends(oauth2_scheme)) -> dict:
    """Invalidate the provided token by storing its JTI in Redis."""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
        )
    jti = payload.get("jti")
    exp = payload.get("exp")
    if not jti or not exp:
        raise HTTPException(status_code=400, detail="Malformed token")
    ttl = int(exp - datetime.now(UTC).timestamp())
    if ttl > 0:
        redis_client.setex(jti, ttl, "1")
    return {"detail": "logged out"}
