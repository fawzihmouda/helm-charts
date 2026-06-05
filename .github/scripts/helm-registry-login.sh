#!/usr/bin/env bash
set -euo pipefail

: "${GHCR_TOKEN:?GHCR_TOKEN is required}"
: "${REGISTRY:?REGISTRY is required}"

printf '%s\n' "${GHCR_TOKEN}" | helm registry login "${REGISTRY}" \
  -u "${GITHUB_ACTOR}" \
  --password-stdin
