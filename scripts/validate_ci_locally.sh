#!/usr/bin/env bash
set -eo pipefail

echo "🔍 DevOnboarder Local CI Validation"
echo "Running exact same validation sequence as GitHub Actions..."
echo

# Ensure virtual environment
if [[ -z "$VIRTUAL_ENV" ]]; then
    echo "⚠️  Activating virtual environment..."
    # shellcheck disable=SC1091 # Runtime source operation
    source .venv/bin/activate
fi

# 1. Generate secrets test
echo "1️⃣  Testing generate-secrets.sh (CI mode)..."
CI=true bash scripts/generate-secrets.sh
echo "✅ Generate secrets: PASSED"
echo

# 2. Environment audit
echo "2️⃣  Testing environment variable audit..."
mkdir -p logs
env -i PATH="$PATH" bash -c 'set -a; source .env.ci; set +a; JSON_OUTPUT=logs/env_audit.json bash scripts/audit_env_vars.sh' > logs/env_audit.log 2>&1

# Check audit results exactly like CI
missing=$(python -c 'import json,sys;print("".join(json.load(open("logs/env_audit.json")).get("missing", [])))')
extras=$(python -c 'import json,sys;d=json.load(open("logs/env_audit.json"));print("".join(e for e in d.get("extra", []) if e not in ("PATH","PWD","SHLVL","_")))')

if [ -n "$missing" ] || [ -n "$extras" ]; then
    echo "❌ Environment audit: FAILED"
    echo "Missing: $missing"
    echo "Extra: $extras"
    exit 1
else
    echo "✅ Environment audit: PASSED"
fi
echo

# 3. Environment docs alignment
echo "3️⃣  Testing environment docs alignment..."
python scripts/check_env_docs.py
echo "✅ Environment docs: PASSED"
echo

# 4. QC Pre-push validation
echo "4️⃣  Running comprehensive QC validation..."
./scripts/qc_pre_push.sh
echo "✅ QC validation: PASSED"
echo

# 5. Python tests
echo "5️⃣  Running Python tests..."
python -m pytest --cov=src --cov-fail-under=95 -q
echo "✅ Python tests: PASSED"
echo

# 6. Bot tests
echo "6️⃣  Building and testing TypeScript bot..."
npm run build --prefix bot --silent
npm test --prefix bot --silent
echo "✅ Bot tests: PASSED"
echo

# 7. Frontend build
echo "7️⃣  Testing frontend build..."
npm run build --prefix frontend --silent
echo "✅ Frontend build: PASSED"
echo

# 8. Docker container build (like CI)
echo "8️⃣  Testing Docker container build..."
docker compose -f docker-compose.ci.yaml --env-file .env.ci build --quiet
echo "✅ Docker build: PASSED"
echo

echo "🎉 All CI validations PASSED locally!"
echo "Safe to push to GitHub - CI should succeed"
