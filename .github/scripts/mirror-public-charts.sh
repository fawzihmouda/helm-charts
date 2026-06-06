#!/usr/bin/env bash
set -euo pipefail

: "${ARTIFACT_REGISTRY:?ARTIFACT_REGISTRY is required}"
: "${MIRROR_MANIFEST:=charts.yaml}"
: "${MIRROR_DRY_RUN:=false}"

case "${MIRROR_DRY_RUN}" in
  true | false) ;;
  *)
    printf 'MIRROR_DRY_RUN must be true or false.\n' >&2
    exit 1
    ;;
esac

if [[ "${ARTIFACT_REGISTRY}" == *"://"* ]]; then
  printf 'ARTIFACT_REGISTRY must not include a URL scheme: %s\n' "${ARTIFACT_REGISTRY}" >&2
  exit 1
fi

if [[ ! -f "${MIRROR_MANIFEST}" ]]; then
  printf 'Mirror manifest not found: %s\n' "${MIRROR_MANIFEST}" >&2
  exit 1
fi

charts_file="$(mktemp)"
dist_dir="${RUNNER_TEMP:-.}/helm-mirror-dist"

cleanup() {
  rm -f "${charts_file}"
  rm -rf "${dist_dir}"
}

parse_manifest() {
  MIRROR_MANIFEST="${MIRROR_MANIFEST}" \
  MIRROR_CHARTS_FILE="${charts_file}" \
  ruby <<'RUBY'
require "yaml"
require "pathname"
require "uri"

def fail_with(message)
  warn(message)
  exit(1)
end

def required_string(hash, key, context)
  value = hash[key]
  fail_with("#{context} must set #{key}") unless value.is_a?(String) && !value.empty?
  fail_with("#{context} #{key} must not contain tabs or newlines") if value.match?(/[\t\r\n]/)
  value
end

def validate_name(value, context, key)
  return if value.match?(/\A[A-Za-z0-9_.-]+\z/)

  fail_with("#{context} #{key} may contain only letters, numbers, dots, underscores, and hyphens")
end

manifest_path = ENV.fetch("MIRROR_MANIFEST")
manifest = YAML.safe_load(File.read(manifest_path), aliases: false, filename: manifest_path)

fail_with("#{manifest_path} must contain a YAML mapping") unless manifest.is_a?(Hash)

charts = manifest["charts"]

fail_with("#{manifest_path} must contain a non-empty charts list") unless charts.is_a?(Array) && !charts.empty?

chart_lines = charts.each_with_index.map do |chart_entry, index|
  context = "charts[#{index}]"
  fail_with("#{context} must be a mapping") unless chart_entry.is_a?(Hash)

  name = required_string(chart_entry, "name", context)
  chart = required_string(chart_entry, "chart", context)
  repository_url = required_string(chart_entry, "repository", context)
  version = required_string(chart_entry, "version", context)

  validate_name(name, context, "name")
  fail_with("#{context} chart must not contain whitespace") if chart.match?(/\s/)
  fail_with("#{context} version must not contain whitespace") if version.match?(/\s/)

  case repository_url
  when /\Ahttps?:\/\//
    fail_with("#{context} repository host is invalid") if URI.parse(repository_url).host.to_s.empty?
    fail_with("#{context} chart must be repo/chart: #{chart}") unless chart.include?("/")
    repository_name = chart.split("/", 2).first
    source_chart = chart
    source_type = "helm"
  when /\Aoci:\/\//
    fail_with("#{context} repository host is invalid") if URI.parse(repository_url).host.to_s.empty?
    fail_with("#{context} chart must not include oci://") if chart.start_with?("oci://")

    chart_path = chart.sub(%r{\A/+}, "")
    fail_with("#{context} chart must not be empty") if chart_path.empty?

    repository_name = "oci"
    source_chart = "#{repository_url.sub(%r{/\z}, "")}/#{chart_path}"
    source_type = "oci"
  else
    chart_path = Pathname.new(repository_url).cleanpath
    fail_with("#{context} local repository path must be relative") if chart_path.absolute?
    fail_with("#{context} local repository path must stay inside the checkout") if chart_path.each_filename.any?("..")
    fail_with("#{context} local repository path must contain Chart.yaml: #{chart_path}") unless File.file?(chart_path.join("Chart.yaml"))
    fail_with("#{context} chart must be the local chart name, not a path: #{chart}") if chart.include?("/")

    repository_name = "local"
    source_chart = chart_path.to_s
    source_type = "local"
  end

  "#{source_type}\t#{repository_name}\t#{repository_url}\t#{name}\t#{source_chart}\t#{version}\n"
end

File.write(ENV.fetch("MIRROR_CHARTS_FILE"), chart_lines.join)
RUBY
}

add_repositories() {
  local source_type
  local repository_name
  local repository_url
  local added_count
  local seen_repositories

  added_count=0
  seen_repositories="$(mktemp)"
  while IFS=$'\t' read -r source_type repository_name repository_url _; do
    if [[ "${source_type}" != "helm" ]]; then
      continue
    fi

    if grep -Fxq "${repository_name}" "${seen_repositories}"; then
      continue
    fi

    helm repo add "${repository_name}" "${repository_url}" --force-update
    printf '%s\n' "${repository_name}" >> "${seen_repositories}"
    added_count="$((added_count + 1))"
  done < "${charts_file}"
  rm -f "${seen_repositories}"

  if [[ "${added_count}" -gt 0 ]]; then
    helm repo update
  fi
}

chart_exists() {
  local chart_name="$1"
  local chart_version="$2"
  local existing_chart_output
  local existing_chart_status
  local target_chart

  target_chart="oci://${ARTIFACT_REGISTRY}/${chart_name}"

  set +e
  existing_chart_output="$(helm show chart "${target_chart}" --version "${chart_version}" 2>&1)"
  existing_chart_status="$?"
  set -e

  if [[ "${existing_chart_status}" -eq 0 ]]; then
    return 0
  fi

  if grep -Eiq 'not found|manifest unknown|name unknown|404|failed to resolve reference' <<< "${existing_chart_output}"; then
    return 1
  fi

  printf 'Failed to check target chart %s %s: %s\n' "${chart_name}" "${chart_version}" "${existing_chart_output}" >&2
  exit 1
}

mirror_release() {
  local source_type="$1"
  local release_name="$2"
  local source_chart="$3"
  local requested_version="$4"
  local chart_name
  local chart_package
  local chart_version
  local package_dir
  local packages=()

  package_dir="${dist_dir}/${release_name}"
  rm -rf "${package_dir}"
  mkdir -p "${package_dir}"

  case "${source_type}" in
    local)
      printf 'Packaging %s %s from %s.\n' "${release_name}" "${requested_version}" "${source_chart}"
      if grep -Eq '^[[:space:]]*dependencies:' "${source_chart}/Chart.yaml"; then
        helm dependency build "${source_chart}"
      fi
      helm package "${source_chart}" --destination "${package_dir}"
      ;;
    helm | oci)
      printf 'Pulling %s %s from %s.\n' "${release_name}" "${requested_version}" "${source_chart}"
      helm pull "${source_chart}" --version "${requested_version}" --destination "${package_dir}"
      ;;
    *)
      printf 'Unsupported source type: %s\n' "${source_type}" >&2
      exit 1
      ;;
  esac

  while IFS= read -r chart_package; do
    packages+=("${chart_package}")
  done < <(find "${package_dir}" -maxdepth 1 -type f -name '*.tgz' -print)

  if [[ "${#packages[@]}" -ne 1 ]]; then
    printf 'Expected one chart package for %s, found %s.\n' "${release_name}" "${#packages[@]}" >&2
    exit 1
  fi

  chart_package="${packages[0]}"
  chart_name="$(helm show chart "${chart_package}" | awk -F': ' '$1 == "name" { print $2; exit }')"
  chart_version="$(helm show chart "${chart_package}" | awk -F': ' '$1 == "version" { print $2; exit }')"

  if [[ -z "${chart_name}" || -z "${chart_version}" ]]; then
    printf 'Could not read chart metadata from %s.\n' "${chart_package}" >&2
    exit 1
  fi

  if [[ "${chart_version}" != "${requested_version}" ]]; then
    printf 'Pulled %s version %s, expected %s.\n' "${chart_name}" "${chart_version}" "${requested_version}" >&2
    exit 1
  fi

  if [[ "${MIRROR_DRY_RUN}" == "true" ]]; then
    printf 'Dry run: would push %s %s to %s.\n' "${chart_name}" "${chart_version}" "${ARTIFACT_REGISTRY}"
    return
  fi

  if chart_exists "${chart_name}" "${chart_version}"; then
    printf 'Skipping %s %s; it already exists in %s.\n' "${chart_name}" "${chart_version}" "${ARTIFACT_REGISTRY}"
    return
  fi

  helm push "${chart_package}" "oci://${ARTIFACT_REGISTRY}"
}

mirror_releases() {
  local source_type
  local repository_name
  local repository_url
  local release_name
  local source_chart
  local requested_version

  rm -rf "${dist_dir}"
  mkdir -p "${dist_dir}"

  while IFS=$'\t' read -r source_type repository_name repository_url release_name source_chart requested_version; do
    mirror_release "${source_type}" "${release_name}" "${source_chart}" "${requested_version}"
  done < "${charts_file}"
}

trap cleanup EXIT

parse_manifest
add_repositories
mirror_releases
