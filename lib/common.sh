#
# Description:
#   Common helpers for toolchain scripts.
#
# Usage:
#   Source this file from toolchain entrypoints in bin/.
#
# Dependencies:
#   bash >= 5.x
#
# Exit codes:
#   0 success
#   1 general error
#   2 invalid arguments
#   3 missing dependency

set -euo pipefail

die() {
  echo "ERROR: $*" >&2
  exit 1
}

warn() {
  echo "WARN: $*" >&2
}

info() {
  echo "INFO: $*" >&2
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: Missing command: $1" >&2
    exit 3
  }
}

toolchain_root() {
  local src_dir
  src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${src_dir}/.." && pwd
}

load_config() {
  local root
  root="$(toolchain_root)"
  # shellcheck source=/dev/null
  source "${root}/config/toolchain.conf"
}

bash_version_check() {
  local required_major="$1"
  local bash_major="${BASH_VERSINFO[0]}"

  if ((bash_major < required_major)); then
    die "Bash >= ${required_major}.x is required. Current: ${BASH_VERSION}"
  fi
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname -s)" == "Linux" ]]
}

brew_prefix() {
  require_cmd brew
  brew --prefix
}

print_alignment_explanation() {
  cat <<'EOF'
This machine is not aligned to the required GNU userland baseline.

Why:
- Scripts are written for GNU tools (grep/sed/date/find/xargs).
- macOS ships BSD variants with incompatible flags/behavior.
- We enforce uniformity to keep scripts universal.

What to do:
- Run: make align
- This will install required GNU tools and set a GNU-first PATH for this toolchain.

EOF
}
