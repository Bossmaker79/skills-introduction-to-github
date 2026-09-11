#!/usr/bin/env bash
# Serve a live, GitHub-accurate preview of the course README (and its images)
# using grip. Open http://localhost:6419/ to view it.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

HOST="${PREVIEW_HOST:-0.0.0.0}"
PORT="${PREVIEW_PORT:-6419}"

exec .cursor/.venv/bin/grip README.md "${HOST}:${PORT}"
