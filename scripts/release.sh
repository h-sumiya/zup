#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBSPEC_FILE="${REPO_ROOT}/pubspec.yaml"

VERSION="$(
  sed -nE 's/^version:[[:space:]]*([^[:space:]]+).*/\1/p' "${PUBSPEC_FILE}" \
    | head -n 1
)"

if [[ -z "${VERSION}" ]]; then
  echo "Failed to read version from ${PUBSPEC_FILE}" >&2
  exit 1
fi

TAG="v${VERSION}"

if git -C "${REPO_ROOT}" rev-parse -q --verify "refs/tags/${TAG}" >/dev/null; then
  echo "Tag already exists: ${TAG}" >&2
  exit 1
fi

echo "Creating tag: ${TAG}"
git -C "${REPO_ROOT}" tag "${TAG}"
echo "Pushing tags"
git -C "${REPO_ROOT}" push --tag
