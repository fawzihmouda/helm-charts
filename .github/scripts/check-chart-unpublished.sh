#!/usr/bin/env bash
set -euo pipefail

: "${CHART_PATH:?CHART_PATH is required}"
: "${CHART_NAMESPACE:?CHART_NAMESPACE is required}"
: "${REGISTRY:?REGISTRY is required}"

chart_name="$(helm show chart "${CHART_PATH}" | awk -F': ' '$1 == "name" { print $2; exit }')"
chart_namespace="$(printf '%s' "${CHART_NAMESPACE}" | tr '[:upper:]' '[:lower:]')"
chart_version="$(helm show chart "${CHART_PATH}" | awk -F': ' '$1 == "version" { print $2; exit }')"

set +e
existing_chart_output="$(helm show chart "oci://${REGISTRY}/${chart_namespace}/${chart_name}" --version "${chart_version}" 2>&1)"
existing_chart_status="$?"
set -e

if [[ "${existing_chart_status}" -eq 0 ]]; then
  printf '::error file=%s/Chart.yaml::%s %s already exists in GHCR. Bump chart version before publishing.\n' \
    "${CHART_PATH}" \
    "${chart_name}" \
    "${chart_version}"
  exit 1
fi

if ! grep -Eiq 'not found|manifest unknown|name unknown|404' <<< "${existing_chart_output}"; then
  printf '::error file=%s/Chart.yaml::Failed to check existing GHCR chart version: %s\n' \
    "${CHART_PATH}" \
    "${existing_chart_output}"
  exit 1
fi
