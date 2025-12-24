#!/usr/bin/env bats
# Description: Smoke tests for bin/shell.sh behavior (non-nested, env missing, banners).
# Usage: bats tests/shell_smoke.bats
# Dependencies: bats, bash
set -euo pipefail

setup() {
  cd "${BATS_TEST_DIRNAME}/.."
}

@test "shell.sh refuses to nest when TOOLCHAIN_SHELL=1" {
  run env TOOLCHAIN_SHELL=1 ./bin/shell.sh 2>&1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already inside toolchain shell"* ]]
}

@test "shell.sh errors clearly if env file is missing" {
  if [[ -f .toolchain/env.sh ]]; then
    mv .toolchain/env.sh .toolchain/env.sh.bak
    trap 'mv .toolchain/env.sh.bak .toolchain/env.sh 2>/dev/null || true' RETURN
  fi

  # NOTE: bats may run inside an existing toolchain shell (TOOLCHAIN_SHELL=1),
  # which would make shell.sh refuse to nest and exit 0. For this test we want
  # the "outside" behavior.
  run env -u TOOLCHAIN_SHELL ./bin/shell.sh 2>&1
  [ "$status" -ne 0 ]
  [[ "$output" == *"Env file not found"* ]]
}

@test "shell.sh exposes ENTER/LEAVE banners via --print-rcfile (CI-friendly)" {
  if [[ ! -f .toolchain/env.sh ]]; then
    skip "env.sh missing; run make setup first"
  fi

  run env -u TOOLCHAIN_SHELL ./bin/shell.sh --print-rcfile 2>&1
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> ENTERING TOOLCHAIN SHELL"* ]]
  [[ "$output" == *"<<< LEAVING TOOLCHAIN SHELL"* ]]
  [[ "$output" == *"PS1='[toolchain"* ]]
}



