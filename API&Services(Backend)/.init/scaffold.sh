#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/test-project-ajay-8050-8164/API&Services(Backend)"
mkdir -p "${WORKSPACE}"
cd "${WORKSPACE}"
# Create minimal FastAPI app only if missing
[ -d "${WORKSPACE}/app" ] || mkdir -p "${WORKSPACE}/app"
if [ ! -f "${WORKSPACE}/app/main.py" ]; then
  cat > "${WORKSPACE}/app/main.py" <<'PY'
from fastapi import FastAPI
app = FastAPI()

@app.get("/health")
def health():
    return {"status":"ok"}
PY
fi
# requirements (do not overwrite if present)
if [ ! -f "${WORKSPACE}/requirements.txt" ]; then
  cat > "${WORKSPACE}/requirements.txt" <<'TXT'
fastapi
uvicorn[standard]
pytest
requests
PyGithub
pygments
astor
celery
TXT
fi
# create resilient start.sh if absent
START_SH="${WORKSPACE}/start.sh"
if [ ! -f "${START_WORKDIR:-$WORKSPACE}/start.sh" ] || [ ! -x "${START_SH}" ]; then
  cat > "${START_SH}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
# Derive WORKDIR from environment or default injected once
WORKDIR_DEFAULT="/home/kavia/workspace/code-generation/test-project-ajay-8050-8164/API&Services(Backend)"
WORKDIR="${WORKDIR:-$WORKDIR_DEFAULT}"
cd "${WORKDIR}"
# Activate venv if present
if [ -f "${WORKDIR}/.venv/bin/activate" ]; then
  # shellcheck disable=SC1091
  source "${WORKDIR}/.venv/bin/activate"
fi
# Start uvicorn bound to 0.0.0.0:8000
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
SH
  chmod +x "${START_SH}"
fi
