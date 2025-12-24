#!/usr/bin/env bats

@test "GNU sed and grep are available and not BSD on macOS" {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    skip "GNU PATH test only relevant on macOS"
  fi

  run sed --version
  [ "$status" -eq 0 ]

  run grep --version
  [ "$status" -eq 0 ]
}
