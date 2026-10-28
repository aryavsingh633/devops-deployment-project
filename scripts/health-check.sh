#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://localhost:8080}"

echo "Checking application at: $URL"

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is not installed."
  exit 1
fi

if ! response=$(curl -fsS --max-time 5 "$URL"); then
  echo "ERROR: Application is unavailable."
  exit 1
fi

if grep -q "My DevOps Project" <<< "$response"; then
  echo "SUCCESS: Application is healthy."
else
  echo "ERROR: Expected application content was not found."
  exit 1
fi
