#!/usr/bin/env bats

@test "bootstrap check runs and returns 0 or 10 (not aligned)" {
  run bash bin/bootstrap.sh check
  [ "$status" -eq 0 ] || [ "$status" -eq 10 ]
}
