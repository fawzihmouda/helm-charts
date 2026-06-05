#!/usr/bin/env bash
set -euo pipefail

: "${CHART_NAMESPACE:?CHART_NAMESPACE is required}"
: "${REGISTRY:?REGISTRY is required}"

chart_namespace="$(printf '%s' "${CHART_NAMESPACE}" | tr '[:upper:]' '[:lower:]')"
chart_packages=(dist/*.tgz)

if [[ ! -e "${chart_packages[0]}" ]]; then
  printf 'No chart packages found under dist.\n' >&2
  exit 1
fi

for chart_package in "${chart_packages[@]}"; do
  helm push "${chart_package}" "oci://${REGISTRY}/${chart_namespace}"
done
