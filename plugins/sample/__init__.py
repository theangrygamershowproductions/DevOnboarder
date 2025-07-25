"""Sample plugin for DevOnboarder."""

MESSAGE = "Sample plugin loaded"


def register() -> str:
    """Return a sample registration message."""
    return MESSAGE
