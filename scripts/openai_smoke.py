#!/usr/bin/env python3
"""Smoke test OpenAI API key validity."""
import json
import os
import sys
import urllib.request

API_KEY = os.getenv("OPENAI_API_KEY")
if not API_KEY:
    print("[ERROR] OPENAI_API_KEY not set", file=sys.stderr)
    sys.exit(42)

req = urllib.request.Request(
    "https://api.openai.com/v1/models",
    headers={"Authorization": f"Bearer {API_KEY}"},
)
try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        if resp.status != 200:
            print(f"[ERROR] API status {resp.status}", file=sys.stderr)
            sys.exit(43)
        json.load(resp)  # ensure valid JSON
except Exception as exc:
    print(f"[ERROR] {exc}", file=sys.stderr)
    sys.exit(43)

print("[OK] OpenAI API credentials valid")
