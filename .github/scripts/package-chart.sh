#!/usr/bin/env bash
set -euo pipefail

: "${CHART_PATH:?CHART_PATH is required}"

if grep -Eq '^[[:space:]]*dependencies:' "${CHART_PATH}/Chart.yaml"; then
  helm dependency build "${CHART_PATH}"
fi

helm package "${CHART_PATH}" --destination dist
