#!/usr/bin/env bash
# Usage:
#   ./bin/ci_only.sh
#
# Description:
#   CI-only unattended gate:
#     - Align machine unattended (installs deps via brew/apt, best effort)
#     - Source .toolchain/env.sh to ensure GNU-first PATH
#     - Run check + lint + tests
#
# Dependencies:
#   bash >= 5.x
#
# Notes:
#   - Intended for CI runners. It performs package-manager installs.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() { printf 'INFO: %s\n' "$*" >&2; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

ensure_macos_gnu_first_path() {
  # Even after sourcing env.sh, enforce the gnubin ordering explicitly on macOS.
  # This avoids CI flakiness when PATH is minimal/modified by the runner.
  [[ "$(uname -s)" == "Darwin" ]] || return 0

  command -v brew >/dev/null 2>&1 || return 0
  local brew_pfx
  brew_pfx="$(brew --prefix 2>/dev/null || true)"
  [[ -n "${brew_pfx}" ]] || return 0

  export PATH="${brew_pfx}/opt/gawk/libexec/gnubin:${brew_pfx}/opt/gnu-sed/libexec/gnubin:${brew_pfx}/opt/grep/libexec/gnubin:${brew_pfx}/opt/findutils/libexec/gnubin:${brew_pfx}/opt/coreutils/libexec/gnubin:${brew_pfx}/bin:${brew_pfx}/sbin:${PATH}"
}

main() {
  # Unattended alignment (both macOS and Linux)
  bash "${root}/bin/bootstrap.sh" align --yes

  if [[ -f "${root}/.toolchain/env.sh" ]]; then
    # shellcheck source=/dev/null
    source "${root}/.toolchain/env.sh"
  else
    die "Env file not found after alignment: ${root}/.toolchain/env.sh"
  fi

  ensure_macos_gnu_first_path

  bash "${root}/bin/bootstrap.sh" check
  bash "${root}/bin/lint.sh" "${LINT_PATH:-.}"
  bash "${root}/bin/test.sh"
}

main "$@"
