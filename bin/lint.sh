#!/usr/bin/env bash
#
# Description:
#   Lint Bash scripts: ShellCheck + shfmt diff + structural Google-style checks.
#
# Usage:
#   lint.sh <file_or_dir> [<file_or_dir>...]
#
# Dependencies:
#   bash >= 5.x, shellcheck, shfmt
#
# Exit codes:
#   0 success
#   1 lint/style failure
#   2 invalid arguments
#   3 missing dependency

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${script_dir}/../lib/common.sh"

timestamp_now() {
  date +"%Y%m%d-%H%M%S"
}

init_reports_dir() {
  local ts
  ts="$(timestamp_now)"
  REPORT_DIR=".toolchain/reports/lint-${ts}"
  mkdir -p "${REPORT_DIR}"
}

init_snapshot_dir() {
  local ts
  ts="$(timestamp_now)"
  SNAPSHOT_DIR=".toolchain/snapshots/lint-${ts}"
  mkdir -p "${SNAPSHOT_DIR}"
}

report_file() {
  local name="$1"
  echo "${REPORT_DIR}/${name}"
}

usage() {
  cat <<EOF
Toolchain lint (v${TOOLCHAIN_VERSION})

Usage:
  $(basename "$0") <file_or_dir> [<file_or_dir>...]

Notes:
  - Runs ShellCheck (bash) and fails on any warning/error.
  - Runs shfmt in diff mode (does not modify files).
  - Enforces minimal structural checks (shebang, header markers, main).

EOF
}

collect_files() {
  local -a inputs=("$@")
  local p

  for p in "${inputs[@]}"; do
    if [[ -f "${p}" ]]; then
      files+=("${p}")
    elif [[ -d "${p}" ]]; then
      while IFS= read -r -d '' f; do
        # Skip intentional bad examples (copilot anti-patterns)
        if [[ "${f}" =~ /bad_.*\.sh$ ]]; then
          continue
        fi
        files+=("${f}")
      done < <(find "${p}" -type f -name "*.sh" -print0)
    else
      die "Path not found: ${p}"
    fi
  done

  printf '%s\n' "${files[@]}"
}

is_library_file() {
  local f="$1"

  # Skip structure enforcement for sourced libraries, config snippets, and generated files.
  case "${f}" in
    */.toolchain/* | */lib/* | */config/*)
      return 0
      ;;
    *) return 1 ;;
  esac
}

check_structure() {
  local f="$1"

  # Skip structure enforcement for sourced libraries, config snippets, and generated files.
  case "${f}" in
    */.toolchain/* | */lib/* | */config/*)
      return 0
      ;;
  esac

  local first_line
  first_line="$(head -n 1 "${f}")"
  if [[ "${first_line}" != "#!/usr/bin/env bash" ]]; then
    # If there is no shebang at all, treat it as a sourced file and skip.
    if [[ "${first_line}" != "#!"* ]]; then
      return 0
    fi

    echo "FAIL: ${f}: invalid shebang (expected #!/usr/bin/env bash)" >&2
    return 1
  fi

  local header_block
  header_block="$(head -n 40 "${f}")"

  if ! grep -qE '^[# ]*Description:' <<<"${header_block}"; then
    echo "FAIL: ${f}: missing header marker 'Description:'" >&2
    return 1
  fi
  if ! grep -qE '^[# ]*Usage:' <<<"${header_block}"; then
    echo "FAIL: ${f}: missing header marker 'Usage:'" >&2
    return 1
  fi
  if ! grep -qE '^[# ]*Dependencies:' <<<"${header_block}"; then
    echo "FAIL: ${f}: missing header marker 'Dependencies:'" >&2
    return 1
  fi

  if ! grep -qE '^[[:space:]]*main[[:space:]]*\(\)[[:space:]]*\{' "${f}"; then
    echo "FAIL: ${f}: missing main() function" >&2
    return 1
  fi

  local last_line
  last_line="$(grep -vE '^[[:space:]]*(#.*)?$' "${f}" | tail -n 1)"
  if [[ "${last_line}" != 'main "$@"' ]]; then
    echo "FAIL: ${f}: last executable line must be: main "\$@"" >&2
    return 1
  fi

  return 0
}

check_crlf() {
  local target="$1"
  if grep -RIl $'
' -- "${target}" 2>/dev/null | grep -E '\.sh$' >/dev/null 2>&1; then
    die "CRLF line endings detected in shell scripts under: ${target}. Convert to LF."
  fi
}

main() {
  load_config
  bash_version_check "${TOOLCHAIN_REQUIRED_BASH_MAJOR}"

  local lint_artifacts="${LINT_ARTIFACTS:-0}"
  local lint_snapshot="${LINT_SNAPSHOT:-0}"
  local REPORT_DIR=""
  local SNAPSHOT_DIR=""

  if [[ "${lint_artifacts}" == "1" ]]; then
    init_reports_dir
  fi
  if [[ "${lint_snapshot}" == "1" ]]; then
    init_snapshot_dir
    # If snapshot mode is enabled, enable reports automatically only for patch output when requested.
    if [[ "${lint_artifacts}" == "1" && -z "${REPORT_DIR}" ]]; then
      init_reports_dir
    fi
  fi

  if (($# == 0)); then
    usage
    exit 2
  fi

  local cmd
  for cmd in "${LINT_REQUIRED_COMMANDS[@]}"; do
    require_cmd "${cmd}"
  done

  mapfile -t files < <(collect_files "$@")

  if ((${#files[@]} == 0)); then
    die "No .sh files found."
  fi

  local fail=0
  local f

  for f in "${files[@]}"; do
    case "${f}" in */.toolchain/*) continue ;; esac
    case "${f}" in */.toolchain/*) continue ;; esac
    info "Linting: ${f}"

    if ! check_structure "${f}"; then
      fail=1
    fi

    if ! shellcheck -s bash "${f}"; then
      fail=1
    fi

    if ! shfmt -i 2 -ci -d "${f}"; then
      fail=1
    fi
  done

  if ((fail == 1)); then
    exit 1
  fi

  info "Lint OK."
}

main "$@"
