#!/usr/bin/env bash
# Idempotent setup for the "Introduction to GitHub" Skills course repository.
# This repo has no application code: it is GitHub-flavored Markdown course
# content plus GitHub Actions workflows. The tools below let an agent preview
# the course exactly as it renders on GitHub and validate the workflow YAML.
set -euo pipefail

ACTIONLINT_VERSION="1.7.12"
LOCAL_BIN="${HOME}/.local/bin"
mkdir -p "${LOCAL_BIN}"

echo "==> Installing grip (GitHub-style Markdown preview server)"
python3 -m pip install --user --quiet --upgrade grip

echo "==> Installing actionlint ${ACTIONLINT_VERSION} (GitHub Actions workflow linter)"
if [ "$("${LOCAL_BIN}/actionlint" --version 2>/dev/null | head -1)" != "${ACTIONLINT_VERSION}" ]; then
  case "$(uname -m)" in
    x86_64|amd64) AL_ARCH="amd64" ;;
    aarch64|arm64) AL_ARCH="arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
  AL_URL="https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_${AL_ARCH}.tar.gz"
  tmp="$(mktemp -d)"
  curl -fsSL "${AL_URL}" -o "${tmp}/actionlint.tar.gz"
  tar -xzf "${tmp}/actionlint.tar.gz" -C "${tmp}" actionlint
  install -m 0755 "${tmp}/actionlint" "${LOCAL_BIN}/actionlint"
  rm -rf "${tmp}"
fi

echo "==> Versions"
"${LOCAL_BIN}/actionlint" --version
"${LOCAL_BIN}/grip" --version || python3 -m grip --version

echo "==> Setup complete. Tools installed to ${LOCAL_BIN}"
