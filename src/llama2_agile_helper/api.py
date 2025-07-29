"""FastAPI service providing sprint summaries and backlog grooming via Llama2."""

from __future__ import annotations

import os
from pathlib import Path

import httpx
from fastapi import APIRouter, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

from utils.cors import get_cors_origins

API_KEY = os.getenv("LLAMA2_API_KEY", "")
API_TIMEOUT = int(os.getenv("LLAMA2_API_TIMEOUT", "10"))
BASE_URL = os.getenv("LLAMA2_URL", "https://api.llama2.ai/generate")
PROMPT_DIR = Path(__file__).resolve().parents[2] / "prompts"

router = APIRouter()


def _load_prompt(name: str) -> str:
    return (PROMPT_DIR / name).read_text()


def _call_llama2(prompt: str) -> str:
    if not API_KEY:
        raise HTTPException(status_code=503, detail="LLAMA2_API_KEY not set")
    try:
        resp = httpx.post(
            BASE_URL,
            json={"prompt": prompt},
            headers={"Authorization": f"Bearer {API_KEY}"},
            timeout=API_TIMEOUT,
        )
    except httpx.TimeoutException as exc:  # pragma: no cover - network issue
        raise HTTPException(status_code=504, detail="Llama2 API timeout") from exc
    resp.raise_for_status()
    data = resp.json()
    return data.get("text", "")


@router.post("/sprint-summary")
def sprint_summary(data: dict[str, str]) -> dict[str, str]:
    """Return a sprint summary generated from raw notes."""
    notes = data["notes"]
    prompt = _load_prompt("retro_analysis.prompt") + "\n" + notes
    summary = _call_llama2(prompt)
    return {"summary": summary}


@router.post("/groom-backlog")
def groom_backlog(data: dict[str, list[str]]) -> dict[str, str]:
    """Return backlog grooming suggestions for the given tickets."""
    tickets = "\n".join(f"- {t}" for t in data["tickets"])
    prompt = _load_prompt("ticket_classifier.prompt") + "\n" + tickets
    suggestions = _call_llama2(prompt)
    return {"suggestions": suggestions}


def create_app() -> FastAPI:
    """Instantiate and configure the FastAPI application."""

    app = FastAPI()
    cors_origins = get_cors_origins()

    class _SecurityHeadersMiddleware(BaseHTTPMiddleware):
        async def dispatch(self, request, call_next):  # type: ignore[override]
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

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    app.include_router(router)
    return app


def main() -> None:  # pragma: no cover - convenience runner
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8100)  # nosec B104


if __name__ == "__main__":  # pragma: no cover
    main()
