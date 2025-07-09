import sys
from pathlib import Path
import types

src_dir = Path(__file__).resolve().parents[1] / "src"
package = types.ModuleType("src")
package.__path__ = [str(src_dir)]
sys.modules.setdefault("src", package)
sys.path.insert(0, str(src_dir))

from src.utils.roles import resolve_user_flags, resolve_verification_type  # noqa: E402
import pytest  # noqa: E402


@pytest.fixture(autouse=True)
def _set_role_env(monkeypatch):
    monkeypatch.setenv("OWNER_ROLE_ID", "owner")
    monkeypatch.setenv("ADMINISTRATOR_ROLE_ID", "admin")
    monkeypatch.setenv("MODERATOR_ROLE_ID", "mod")
    monkeypatch.setenv("VERIFIED_USER_ROLE_ID", "v_user")
    monkeypatch.setenv("VERIFIED_MEMBER_ROLE_ID", "v_member")
    monkeypatch.setenv("GOVERNMENT_ROLE_ID", "gov")
    monkeypatch.setenv("MILITARY_ROLE_ID", "mil")
    monkeypatch.setenv("EDUCATION_ROLE_ID", "edu")


def test_resolve_verification_type_all_roles():
    assert resolve_verification_type(["gov"]) == "government"
    assert resolve_verification_type(["mil"]) == "military"
    assert resolve_verification_type(["edu"]) == "education"
    assert resolve_verification_type(["v_member"]) == "member"
    assert resolve_verification_type(["v_user"]) == "member"
    assert resolve_verification_type([]) is None


@pytest.mark.parametrize("admin_key,role", [
    ("OWNER_ROLE_ID", "owner"),
    ("ADMINISTRATOR_ROLE_ID", "admin"),
    ("MODERATOR_ROLE_ID", "mod"),
])
def test_resolve_user_flags_admin_only(monkeypatch, admin_key, role):
    flags = resolve_user_flags([role])
    assert flags == {
        "isAdmin": True,
        "isVerified": False,
        "verificationType": None,
    }


@pytest.mark.parametrize("admin_role", ["owner", "admin", "mod"])
@pytest.mark.parametrize(
    "verification_role,expected",
    [
        ("gov", "government"),
        ("mil", "military"),
        ("edu", "education"),
        ("v_member", "member"),
        ("v_user", "member"),
    ],
)
def test_resolve_user_flags_admin_and_verified(admin_role, verification_role, expected):
    flags = resolve_user_flags([admin_role, verification_role])
    assert flags == {
        "isAdmin": True,
        "isVerified": True,
        "verificationType": expected,
    }


def test_resolve_user_flags_verified_only():
    flags = resolve_user_flags(["edu"])
    assert flags == {
        "isAdmin": False,
        "isVerified": True,
        "verificationType": "education",
    }


def test_resolve_user_flags_no_roles():
    assert resolve_user_flags([]) == {
        "isAdmin": False,
        "isVerified": False,
        "verificationType": None,
    }
