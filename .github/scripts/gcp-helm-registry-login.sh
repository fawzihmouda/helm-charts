#!/usr/bin/env bash
set -euo pipefail

: "${ARTIFACT_REGISTRY:?ARTIFACT_REGISTRY is required}"
: "${GCP_ACCESS_TOKEN:?GCP_ACCESS_TOKEN is required}"

if [[ "${ARTIFACT_REGISTRY}" == *"://"* ]]; then
  printf 'ARTIFACT_REGISTRY must not include a URL scheme: %s\n' "${ARTIFACT_REGISTRY}" >&2
  exit 1
fi

registry_host="${ARTIFACT_REGISTRY%%/*}"

if [[ -z "${registry_host}" || "${registry_host}" == "${ARTIFACT_REGISTRY}" ]]; then
  printf 'ARTIFACT_REGISTRY must be host/project/repository: %s\n' "${ARTIFACT_REGISTRY}" >&2
  exit 1
fi

printf '%s\n' "${GCP_ACCESS_TOKEN}" | helm registry login "https://${registry_host}" \
  -u oauth2accesstoken \
  --password-stdin
