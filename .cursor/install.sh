#!/usr/bin/env bash
# Idempotent setup for the "Introduction to GitHub" course content repo.
# Installs local, self-contained tooling to preview the README exactly as
# GitHub renders it (grip) and to validate the course content:
#   - grip           GitHub-accurate README preview server (Python)
#   - yamllint       lint the GitHub Actions workflow YAML (Python)
#   - actionlint     validate the GitHub Actions workflows (static binary)
#   - markdownlint   lint the course Markdown (Node)
#
# Everything is installed under .cursor/ so the repo working tree stays clean
# and no root/apt access is required (the Ubuntu package archive is not
# reachable from Cloud Agent VMs).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

VENV_DIR=".cursor/.venv"
BIN_DIR=".cursor/bin"
NODE_TOOLS_DIR=".cursor/node_tools"
ACTIONLINT_VERSION="1.7.12"

echo "==> Python tooling (grip, yamllint)"
if [ ! -x "$VENV_DIR/bin/python" ]; then
  # python3-venv/ensurepip is unavailable in the base image, so seed the
  # environment with virtualenv (which bundles its own pip).
  python3 -m virtualenv --version >/dev/null 2>&1 || \
    pip install --user --break-system-packages --quiet virtualenv
  python3 -m virtualenv -q "$VENV_DIR"
fi
"$VENV_DIR/bin/pip" install --quiet --upgrade grip yamllint

echo "==> actionlint ${ACTIONLINT_VERSION}"
if [ "$("$BIN_DIR/actionlint" --version 2>/dev/null | head -1)" != "$ACTIONLINT_VERSION" ]; then
  mkdir -p "$BIN_DIR"
  curl -sSfL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash \
    | bash -s -- "$ACTIONLINT_VERSION" "$BIN_DIR" >/dev/null
fi

echo "==> markdownlint-cli"
if [ ! -x "$NODE_TOOLS_DIR/node_modules/.bin/markdownlint" ]; then
  mkdir -p "$NODE_TOOLS_DIR"
  npm install --prefix "$NODE_TOOLS_DIR" --no-fund --no-audit --silent markdownlint-cli
fi

echo ""
echo "Tooling ready:"
echo "  grip preview : $VENV_DIR/bin/grip"
"$VENV_DIR/bin/grip" --version
"$VENV_DIR/bin/yamllint" --version
"$BIN_DIR/actionlint" --version | head -1
"$NODE_TOOLS_DIR/node_modules/.bin/markdownlint" --version
