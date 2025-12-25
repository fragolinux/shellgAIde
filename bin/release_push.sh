#!/usr/bin/env bash
#
# Description:
#   Push main and the latest version tag after verifying local state.
#
# Usage:
#   ./bin/release_push.sh
#
# Dependencies:
#   bash >= 5.x, git

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
  local latest_tag
  local tag_commit
  local head_commit

  require_cmd git

  if [[ -n "$(git status --porcelain)" ]]; then
    die "Working tree is not clean. Commit or stash first."
  fi

  latest_tag="$(git --no-pager tag -l 'v*' --sort=-v:refname | head -n 1)"
  [[ -n "${latest_tag}" ]] || die "No version tag found (vX.Y.Z)."

  tag_commit="$(git rev-list -n 1 "${latest_tag}")"
  head_commit="$(git rev-parse HEAD)"
  if [[ "${tag_commit}" != "${head_commit}" ]]; then
    die "Latest tag ${latest_tag} does not point to HEAD."
  fi

  info "Pushing main and tag ${latest_tag}..."
  git push origin main
  git push origin "${latest_tag}"
}

main "$@"
