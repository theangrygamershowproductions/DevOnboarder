from __future__ import annotations

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from utils.discord import get_user_roles, get_user_profile
from utils.roles import resolve_user_flags
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

SECRET_KEY = os.getenv("AUTH_SECRET_KEY", "secret")
ALGORITHM = "HS256"

Base = declarative_base()
engine = create_engine(
    os.getenv("AUTH_DATABASE_URL", "sqlite:///./auth.db"),
    connect_args={"check_same_thread": False},
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
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
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)


def get_db() -> Session:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def create_token(user: User) -> str:
    return jwt.encode({"sub": str(user.id)}, SECRET_KEY, algorithm=ALGORITHM)


security = HTTPBearer()


def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    token = creds.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
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

    # Fetch Discord roles and resolve verification/admin flags
    roles = get_user_roles(str(user_id), token)
    all_role_ids = {r for rs in roles.values() for r in rs}
    flags = resolve_user_flags(all_role_ids)

    profile = get_user_profile(token)

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


@app.post("/api/register")
def register(data: dict, db: Session = Depends(get_db)) -> dict[str, str]:
    username = data["username"]
    password = data["password"]
    if db.query(User).filter_by(username=username).first():
        raise HTTPException(status_code=400, detail="Username exists")
    user = User(username=username, password_hash=pwd_context.hash(password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"token": create_token(user)}


@app.post("/api/login")
def login(data: dict, db: Session = Depends(get_db)) -> dict[str, str]:
    username = data["username"]
    password = data["password"]
    user = db.query(User).filter_by(username=username).first()
    if not user or not pwd_context.verify(password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid credentials")
    return {"token": create_token(user)}




@app.get("/api/user/onboarding-status")
def onboarding_status(current_user: User = Depends(get_current_user)) -> dict[str, str]:
    status_str = "complete" if current_user.contributions else "pending"
    return {"status": status_str}


@app.get("/api/user/level")
def user_level(current_user: User = Depends(get_current_user)) -> dict[str, int]:
    xp_total = sum(evt.xp for evt in current_user.events)
    level = xp_total // 100 + 1
    return {"level": level}


@app.get("/api/user/contributions")
def user_contributions(
    current_user: User = Depends(get_current_user),
) -> dict[str, list[str]]:
    return {
        "contributions": [c.description for c in current_user.contributions]
    }


@app.post("/api/user/promote")
def promote(
    data: dict,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Admin required")
    target = db.query(User).filter_by(username=data["username"]).first()
    if not target:
        raise HTTPException(status_code=404, detail="User not found")
    target.is_admin = True
    db.commit()
    return {"promoted": target.username}


def create_app() -> FastAPI:
    init_db()
    from routes.user import router as user_router
    app.include_router(user_router)
    return app


def main() -> None:
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8002)

