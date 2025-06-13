#!/usr/bin/env bash
set -euo pipefail

echo ">> BOOTSTRAP START <<"

# 1) Create & activate venv
python3 -m venv .venv
source .venv/bin/activate

# 2) Upgrade pip
pip install --upgrade pip setuptools wheel

# 3) (Optional) install any dev requirements
if [ -f requirements-dev.txt ]; then
   pip install --requirement requirements-dev.txt
fi

echo ">> BOOTSTRAP END <<"
