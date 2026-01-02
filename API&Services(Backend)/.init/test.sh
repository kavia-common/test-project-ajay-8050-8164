#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/test-project-ajay-8050-8164/API&Services(Backend)"
cd "${WORKSPACE}"
# create a minimal pytest that uses TestClient
mkdir -p tests
cat > tests/test_health.py <<'PY'
from fastapi.testclient import TestClient
from app.main import app

def test_health():
    client = TestClient(app)
    r = client.get('/health')
    assert r.status_code == 200
    assert r.json().get('status') == 'ok'
PY
# run pytest inside venv
# shellcheck disable=SC1091
source .venv/bin/activate
pytest -q || exit $?
