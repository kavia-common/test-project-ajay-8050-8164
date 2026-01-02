#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/test-project-ajay-8050-8164/API&Services(Backend)"
cd "${WORKSPACE}"
START_SH="${WORKSPACE}/start.sh"
if [ ! -x "${START_SH}" ]; then
  echo "start.sh missing or not executable" >&2
  exit 4
fi
LOGFILE=$(mktemp)
export WORKDIR="${WORKSPACE}"
# Start under setsid to create a process group; redirect output to log
setsid "${START_SH}" >"${LOGFILE}" 2>&1 &
PID=$!
# Allow child processes to settle, then capture PGID
sleep 0.5
# PGID may be same as PID's pgid
PGID=$(ps -o pgid= "${PID}" 2>/dev/null | tr -d ' ' || true)
# helper to check PID command line to avoid killing unrelated processes
pid_matches() {
  if ps -p "${PID}" -o args= 2>/dev/null | grep -q -E 'start.sh|uvicorn|python'; then
    return 0
  fi
  return 1
}
cleanup() {
  if [ -n "${PGID}" ]; then
    if pid_matches; then
      kill -TERM -"${PGID}" >/dev/null 2>&1 || true
      sleep 2
      if pid_matches; then
        kill -KILL -"${PGID}" >/dev/null 2>&1 || true
      fi
    fi
  fi
}
trap cleanup EXIT INT TERM
# Readiness loop (configurable timeout)
VALIDATION_TIMEOUT=${VALIDATION_TIMEOUT:-60}
i=0
while [ $i -lt "${VALIDATION_TIMEOUT}" ]; do
  if curl -sS --fail http://127.0.0.1:8000/health >/dev/null 2>&1; then
    break
  fi
  sleep 1; i=$((i+1))
done
if [ $i -ge "${VALIDATION_TIMEOUT}" ]; then
  echo "Validation failed: server did not respond within ${VALIDATION_TIMEOUT}s" >&2
  echo "---- server log (last 200 lines) ----" >&2
  tail -n 200 "${LOGFILE}" >&2 || true
  exit 3
fi
# Show evidence
curl -sS http://127.0.0.1:8000/health || true
# Cleanup (trap will terminate the process group)
cleanup
# Print last part of logs for evidence
tail -n 200 "${LOGFILE}" || true
rm -f "${LOGFILE}"
