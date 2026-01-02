#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/test-project-ajay-8050-8164/API&Services(Backend)"
cd "${WORKSPACE}"
# Create or reuse venv
python3 -m venv .venv || true
# Ensure pip up-to-date in venv
# shellcheck disable=SC1091
source .venv/bin/activate
python -m pip install --upgrade pip >/dev/null
# Install requirements from requirements.txt (skip editable/vcs lines)\nREQS="requirements.txt"
if [ -f "${REQS}" ]; then
  grep -vE '^(\-e|git\+|file:)' "${REQS}" | xargs -r python -m pip install --no-cache-dir -q || true
fi
# verify basic imports
python - <<'PY'
import sys
reqs = ("fastapi","uvicorn","pytest")
missing = []
for r in reqs:
    try:
        __import__(r)
    except Exception:
        missing.append(r)
if missing:
    print("Missing imports:", missing, file=sys.stderr)
    sys.exit(2)
print("dependencies-ok")
PY
