#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/test-project-ajay-8050-8164/API&Services(Backend)"
cd "${WORKSPACE}"
START_SH="${WORKSPACE}/start.sh"
if [ ! -x "${START_SH}" ]; then
  echo "start.sh missing or not executable" >&2
  exit 4
fi
# Use setsid to create a new process group; redirect output to stdout/stderr
setsid "${START_SH}" >/dev/null 2>&1 &
# echo PID for caller
echo $!
