#!/usr/bin/env bats

@test "lint passes on good fixture (assuming lint deps installed)" {
  if ! command -v shellcheck >/dev/null 2>&1; then
    skip "shellcheck not installed"
  fi
  if ! command -v shfmt >/dev/null 2>&1; then
    skip "shfmt not installed"
  fi

  run bash bin/lint.sh tests/fixtures/good_script.sh
  [ "$status" -eq 0 ]
}
