#!/usr/bin/env bash
# Description: Open an interactive "toolchain shell" with GNU-first PATH loaded.
# Usage:
#   ./bin/shell.sh
#   ./bin/shell.sh --print-rcfile   # prints the rcfile content used for the toolchain shell (CI/testing)
# Dependencies: bash, mktemp

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.toolchain/env.sh"

info() { printf 'INFO: %s\n' "$*" >&2; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

get_toolchain_version() {
  # Read version without sourcing files (avoids readonly collisions).
  local v=""
  if [[ -f "${ROOT_DIR}/VERSION" ]]; then
    v="$(tr -d ' \t\r\n' <"${ROOT_DIR}/VERSION")"
  fi
  if [[ -f "${ROOT_DIR}/config/toolchain.conf" ]]; then
    [[ -n "${v}" ]] || v="$(grep -E '^TOOLCHAIN_VERSION=' "${ROOT_DIR}/config/toolchain.conf" | head -n1 | cut -d= -f2- | tr -d '"')"
  fi
  if [[ -n "${v}" ]]; then
    :
  else
    # Fallback: derive from directory name (e.g., toolchain-v2.2.11)
    v="$(basename "${ROOT_DIR}" | sed -n 's/^toolchain-v//p')"
  fi
  [[ -n "${v}" ]] || v="unknown"
  printf '%s' "${v}"
}

render_rcfile() {
  local version
  version="$(get_toolchain_version)"

  cat <<EOF
# Toolchain shell rcfile (generated at runtime)
export TOOLCHAIN_SHELL=1
export TOOLCHAIN_VERSION="${version}"
export TOOLCHAIN_ROOT="${ROOT_DIR}"

# Visible "you are inside toolchain shell" prompt marker
export PS1='[toolchain ${version}] \u@\h:\w\$ '

echo ">>> ENTERING TOOLCHAIN SHELL (v${version})  root=${ROOT_DIR}"

# Always show a leave banner when the interactive shell exits
toolchain__leave_banner() {
  echo "<<< LEAVING TOOLCHAIN SHELL (v${version})"
}
trap toolchain__leave_banner EXIT
EOF
}

load_env() {
  if [[ ! -f "${ENV_FILE}" ]]; then
    die "Env file not found: ${ENV_FILE}. Run: make setup (or make align)"
  fi
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
}

main() {
  if [[ "${1:-}" == "--print-rcfile" ]]; then
    render_rcfile
    return 0
  fi

  if [[ "${TOOLCHAIN_SHELL:-0}" == "1" ]]; then
    warn "Already inside toolchain shell; not starting a nested shell."
    return 0
  fi

  load_env
  info "Toolchain environment loaded (GNU-first PATH)."
  info "Starting toolchain shell (type: exit to return)..."

  local rcfile
  rcfile="$(mktemp "${TMPDIR:-/tmp}/toolchain-rcfile.XXXXXX")"
  render_rcfile >"${rcfile}"

  # Start an interactive bash with the rcfile. Always return 0 to the caller
  # so `make shell` doesn't error just because user typed `exit`.
  /usr/bin/env bash --noprofile --rcfile "${rcfile}" -i || true

  rm -f "${rcfile}" || true
  return 0
}

main "$@"
