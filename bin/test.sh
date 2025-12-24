#!/usr/bin/env bash
#
# Description:
#   Run toolchain automated tests (Bats).
#
# Usage:
#   test.sh
#
# Dependencies:
#   bash >= 5.x, bats
#
# Exit codes:
#   0 success
#   1 test failure
#   3 missing dependency

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${script_dir}/../lib/common.sh"

main() {
  load_config
  bash_version_check "${TOOLCHAIN_REQUIRED_BASH_MAJOR}"
  require_cmd bats

  local root
  root="$(cd "${script_dir}/.." && pwd)"

  bats "${root}/tests"
}

main "$@"
