#!/usr/bin/env bash
#
# Description: Minimal compliant script example
# Usage: good_minimal.sh <name>
# Dependencies: GNU coreutils

set -euo pipefail

# Globals
readonly GREETING="Hello"

# Print error and exit
die() {
  echo "ERROR: $*" >&2
  exit 1
}

# Greet the user
greet() {
  local name="$1"
  echo "${GREETING}, ${name}!"
}

# Main entry point
main() {
  [[ $# -eq 1 ]] || die "Usage: $0 <name>"
  greet "$1"
}

main "$@"
