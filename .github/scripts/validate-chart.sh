#!/usr/bin/env bash
set -euo pipefail

: "${CHART_PATH:?CHART_PATH is required}"

api_versions=()

if [[ -f "${CHART_PATH}/ci/api-versions.txt" ]]; then
  while IFS= read -r api_version; do
    if [[ -n "${api_version}" && ! "${api_version}" =~ ^[[:space:]]*# ]]; then
      api_versions+=("--api-versions=${api_version}")
    fi
  done < "${CHART_PATH}/ci/api-versions.txt"
fi

if grep -Eq '^[[:space:]]*dependencies:' "${CHART_PATH}/Chart.yaml"; then
  helm dependency build "${CHART_PATH}"
fi

helm lint "${CHART_PATH}"

rendered_fixture_count=0
for values_file in "${CHART_PATH}/example.yaml" "${CHART_PATH}"/examples/*.yaml "${CHART_PATH}"/ci/*.yaml; do
  if [[ -f "${values_file}" ]]; then
    rendered_fixture_count="$((rendered_fixture_count + 1))"
    helm lint "${CHART_PATH}" -f "${values_file}"
    helm template "$(basename "${CHART_PATH}")" "${CHART_PATH}" -f "${values_file}" "${api_versions[@]}" > /dev/null
  fi
done

if [[ "${rendered_fixture_count}" -eq 0 ]]; then
  printf '::error file=%s/Chart.yaml::Add at least one render fixture: example.yaml, examples/*.yaml, or ci/*.yaml.\n' "${CHART_PATH}"
  exit 1
fi
