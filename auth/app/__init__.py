# PATCHED v0.2.6 auth/app/__init__.py — Export FastAPI instance from main

"""Expose the FastAPI application for the auth service."""

from .main import app

__all__ = ["app"]
