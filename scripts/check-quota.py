#!/usr/bin/env python3
# PATCHED v0.1.0 scripts/check-quota.py — check OpenAI budget usage

"""Exit non-zero if OpenAI spend >= 80% of budget."""
import datetime as _dt
import json
import os
import sys
import urllib.parse
import urllib.request

API_KEY = os.getenv("OPENAI_API_KEY")
BUDGET = float(os.getenv("OPENAI_BUDGET_USD", "15"))
if not API_KEY:
    print("OPENAI_API_KEY not set", file=sys.stderr)
    sys.exit(42)

today = _dt.date.today()
start = today.replace(day=1).isoformat()
end = today.isoformat()
url = (
    "https://api.openai.com/dashboard/billing/usage?"
    f"{urllib.parse.urlencode({'start_date': start, 'end_date': end})}"
)
req = urllib.request.Request(
    url,
    headers={"Authorization": f"Bearer {API_KEY}"},
)
try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        if resp.status != 200:
            print(f"API status {resp.status}", file=sys.stderr)
            sys.exit(43)
        data = json.load(resp)
        usage = data.get("total_usage", 0) / 100
except Exception as exc:
    print(f"{exc}", file=sys.stderr)
    sys.exit(43)

if BUDGET and usage / BUDGET >= 0.8:
    print(f"[ALERT] Spent ${usage:.2f} of ${BUDGET}")
    sys.exit(1)

print(f"[OK] Spent ${usage:.2f} of ${BUDGET}")
