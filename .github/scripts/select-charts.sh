#!/usr/bin/env bash
set -euo pipefail

charts=()
charts_root="${CHARTS_ROOT:-charts}"
max_charts="${MAX_CHARTS:-256}"

list_all_charts() {
  find "${charts_root}" -mindepth 2 -maxdepth 2 -name Chart.yaml -print |
    sed 's#/Chart.yaml$##' |
    sort
}

list_changed_charts() {
  if [[ -z "${BASE_SHA:-}" || "${BASE_SHA}" =~ ^0+$ ]]; then
    list_all_charts
    return
  fi

  if ! git cat-file -e "${BASE_SHA}^{commit}" || ! git cat-file -e "${HEAD_SHA}^{commit}"; then
    list_all_charts
    return
  fi

  changed_files="$(git diff --name-only "${BASE_SHA}" "${HEAD_SHA}")"

  if grep -Eq "^\\.github/(scripts/|workflows/publish-charts\\.yaml$)" <<< "${changed_files}"; then
    list_all_charts
    return
  fi

  printf '%s\n' "${changed_files}" |
    awk -F/ '$1 == "charts" && NF >= 3 { print $1 "/" $2 }' |
    sort -u |
    while IFS= read -r chart_path; do
      if [[ -f "${chart_path}/Chart.yaml" ]]; then
        printf '%s\n' "${chart_path}"
      fi
    done
}

load_charts() {
  local chart_list_file
  chart_list_file="$(mktemp)"

  "$@" > "${chart_list_file}"
  while IFS= read -r chart_path; do
    if [[ -n "${chart_path}" ]]; then
      charts+=("${chart_path}")
    fi
  done < "${chart_list_file}"

  rm -f "${chart_list_file}"
}

validate_chart_catalogue() {
  local chart_dir
  local chart_name
  local chart_path
  local seen_chart_names

  seen_chart_names="$(mktemp)"
  while IFS= read -r chart_path; do
    chart_dir="$(basename "${chart_path}")"
    chart_name="$(helm show chart "${chart_path}" | awk -F': ' '$1 == "name" { print $2; exit }')"

    if [[ -z "${chart_name}" ]]; then
      printf 'Chart name not found in %s/Chart.yaml\n' "${chart_path}" >&2
      exit 1
    fi

    if [[ "${chart_name}" != "${chart_dir}" ]]; then
      printf 'Chart name must match directory name: %s has name %s\n' "${chart_path}" "${chart_name}" >&2
      exit 1
    fi

    if grep -Fxq "${chart_name}" "${seen_chart_names}"; then
      printf 'Duplicate chart name: %s\n' "${chart_name}" >&2
      exit 1
    fi

    printf '%s\n' "${chart_name}" >> "${seen_chart_names}"
  done < <(list_all_charts)
  rm -f "${seen_chart_names}"
}

load_charts list_changed_charts
validate_chart_catalogue

if [[ "${#charts[@]}" -gt "${max_charts}" ]]; then
  printf 'Selected %s charts, but GitHub matrix jobs support at most %s.\n' "${#charts[@]}" "${max_charts}" >&2
  printf 'Run a smaller chart group instead.\n' >&2
  exit 1
fi

charts_json="$(printf '%s\n' "${charts[@]}" | python3 -c 'import json, sys; print(json.dumps([line.strip() for line in sys.stdin if line.strip()]))')"

printf 'chart_count=%s\n' "${#charts[@]}" >> "${GITHUB_OUTPUT}"
printf 'charts_json=%s\n' "${charts_json}" >> "${GITHUB_OUTPUT}"
