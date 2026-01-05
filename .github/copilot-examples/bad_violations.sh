#!/bin/bash
# VIOLATIONS: missing header markers, no set -euo pipefail

GLOBAL_VAR="test"  # VIOLATION: should be readonly

function bad_func {  # VIOLATION: 'function' keyword not needed
  var=$1  # VIOLATION: not quoted, not local
  [ -f $var ]  # VIOLATION: [ ] instead of [[ ]], not quoted
  echo `ls -l $var`  # VIOLATION: backticks, parsing ls
}

if [ $# -gt 0 ]  # VIOLATION: [ ] instead of [[ ]]
then  # VIOLATION: then on separate line
  bad_func $1  # VIOLATION: not quoted
fi

# VIOLATION: no main() function, no main "$@"
