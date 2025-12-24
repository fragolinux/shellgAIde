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
  run env ENV_FILE="${BATS_TEST_TMPDIR}/nope/env.sh" ./bin/shell.sh 2>&1
  [ "$status" -ne 0 ]
  [[ "$output" == *"Env file not found"* ]]
}

@test "shell.sh exposes ENTER/LEAVE banners via --print-rcfile (CI-friendly)" {
  run ./bin/shell.sh --print-rcfile
  [ "$status" -eq 0 ]
  [[ "$output" == *">>> ENTERING TOOLCHAIN SHELL"* ]]
  [[ "$output" == *"<<< LEAVING TOOLCHAIN SHELL"* ]]
}
