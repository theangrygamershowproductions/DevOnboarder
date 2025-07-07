import sys
from pathlib import Path
import types

src_dir = Path(__file__).resolve().parents[1] / "src"
package = types.ModuleType("src")
package.__path__ = [str(src_dir)]
sys.modules.setdefault("src", package)
sys.path.insert(0, str(src_dir))

from src.utils.roles import resolve_user_flags  # noqa: E402


def test_resolve_user_flags_admin_and_verified(monkeypatch):
    """Return flags when admin and verified roles are present."""
    monkeypatch.setenv("OWNER_ROLE_ID", "owner")
    monkeypatch.setenv("ADMINISTRATOR_ROLE_ID", "admin")
    monkeypatch.setenv("MODERATOR_ROLE_ID", "mod")
    monkeypatch.setenv("VERIFIED_USER_ROLE_ID", "verified")
    monkeypatch.setenv("VERIFIED_MEMBER_ROLE_ID", "vmember")
    monkeypatch.setenv("GOVERNMENT_ROLE_ID", "gov")
    monkeypatch.setenv("MILITARY_ROLE_ID", "mil")
    monkeypatch.setenv("EDUCATION_ROLE_ID", "edu")

    flags = resolve_user_flags(["admin", "verified"])
    assert flags == {
        "isAdmin": True,
        "isVerified": True,
        "verificationType": "member",
    }
