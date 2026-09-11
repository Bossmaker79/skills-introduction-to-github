#!/usr/bin/env bash
# Validate the course content: GitHub Actions workflows and Markdown.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

status=0

echo "==> actionlint (.github/workflows)"
if .cursor/bin/actionlint; then
  echo "    OK"
else
  status=1
fi

echo "==> yamllint (.github)"
if .cursor/.venv/bin/yamllint -c .cursor/yamllint.yml .github; then
  echo "    OK"
else
  status=1
fi

echo "==> markdownlint (course Markdown)"
if .cursor/node_tools/node_modules/.bin/markdownlint \
    --config .cursor/markdownlint.json README.md .github/steps; then
  echo "    OK"
else
  status=1
fi

exit "$status"
