#!/usr/bin/env bash
#
# Description:
#   Run Commitizen bump and show a short verification summary.
#
# Usage:
#   ./bin/release_bump.sh
#
# Dependencies:
#   bash >= 5.x, commitizen (cz), git

set -euo pipefail

info() { printf 'INFO: %s\n' "$*" >&2; }
die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

main() {
  require_cmd cz
  require_cmd git

  if [[ -n "$(git status --porcelain)" ]]; then
    die "Working tree is not clean. Commit or stash first."
  fi

  info "Running: cz bump"
  cz bump

  info "Verifying bump results..."
  git --no-pager log -1 --oneline
  git --no-pager tag -l | tail -n 5
  sed -n '1,40p' CHANGELOG.md
}

main "$@"
