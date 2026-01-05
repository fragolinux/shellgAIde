#!/usr/bin/env bash
#
# Description: Script with command-line parsing and file processing
# Usage: good_fileproc.sh [--verbose] [--prefix PREFIX] <input_file>
# Dependencies: GNU grep, GNU sed

set -euo pipefail

# Globals
readonly SCRIPT_NAME="${0##*/}"
VERBOSE=0
PREFIX=""

# Print error and exit
die() {
  echo "ERROR: $*" >&2
  exit 1
}

# Print usage
usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <input_file>

Process input file with optional prefix.

Options:
  --verbose         Enable verbose output
  --prefix PREFIX   Add prefix to each line
  -h, --help        Show this help

Arguments:
  input_file        File to process

EOF
  exit 0
}

# Log message if verbose
log() {
  if [[ "${VERBOSE}" -eq 1 ]]; then
    echo "[LOG] $*" >&2
  fi
}

# Process the file
process_file() {
  local file="$1"
  local prefix="$2"

  [[ -f "${file}" ]] || die "File not found: ${file}"
  [[ -r "${file}" ]] || die "File not readable: ${file}"

  log "Processing: ${file}"

  if [[ -n "${prefix}" ]]; then
    sed "s/^/${prefix}/" "${file}"
  else
    cat "${file}"
  fi
}

# Main entry point
main() {
  local input_file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verbose)
        VERBOSE=1
        shift
        ;;
      --prefix)
        [[ -n "${2:-}" ]] || die "Missing value for --prefix"
        PREFIX="$2"
        shift 2
        ;;
      -h | --help)
        usage
        ;;
      -*)
        die "Unknown option: $1"
        ;;
      *)
        [[ -z "${input_file}" ]] || die "Multiple files not supported"
        input_file="$1"
        shift
        ;;
    esac
  done

  [[ -n "${input_file}" ]] || die "Missing required argument: input_file"

  process_file "${input_file}" "${PREFIX}"
}

main "$@"
