---
description: 'GNU-first Bash scripting standards for shellgAIde'
applyTo: '**/*.sh, **/*.bash'
---

Follow these rules when creating or modifying Bash scripts in this repo.

**Core requirements**
- Bash >= 5.x.
- GNU userland only: `grep`, `sed`, `awk`, `date`, `find`, `xargs`.
- No OS-compat branches (no macOS/BSD fallbacks, no `gsed`, no `gdate`).
- Google Shell Style Guide compliance.

**Mandatory script structure (executable scripts)**
Every executable script must include:
- `#!/usr/bin/env bash`
- Header (within first 40 lines) containing:
  - `Description:`
  - `Usage:`
  - `Dependencies:`
- `set -euo pipefail`
- Globals declared near the top
- `main()` entry point and final `main "$@"`

**Safety and correctness**
- Always quote variables: `"$var"`.
- Use `[[ ... ]]` (not `[ ... ]`).
- Use `$(...)` (not backticks).
- Never use `eval`.
- Never parse `ls` output.
- Use arrays (avoid word-splitting).
- Use `read -r`.

**Naming**
- Globals/constants: `UPPER_CASE`.
- Locals/functions: `lower_case_with_underscores`.

**Error handling**
- Errors must go to stderr.
- Prefer a `die()` helper.
- Use meaningful exit codes.

**Formatting**
- 2-space indentation.
- One command per line.
- Avoid trailing whitespace.
- Lines <= 80 chars when practical.
- Multi-line conditions: put `&&`/`||` at end of line (no backslashes).
- Redirections: `<<<"${var}"` (no space after `<<<`).
- `case` patterns: `-h | --help)` (space around `|`).

**Hard gates**
- Zero ShellCheck warnings:
  - `shellcheck -s bash <file>`
- Formatting must pass:
  - `shfmt -i 2 -bn -ci -sr -d <file>`
- Repo toolchain must pass:
  - `make lint`
  - `make ci`

**Single source of truth**
- Canonical rules: [PROMPT_SYSTEM.md](../../PROMPT_SYSTEM.md)
- Examples:
  - Good: [.github/copilot-examples/good_minimal.sh](../copilot-examples/good_minimal.sh)
  - Good: [.github/copilot-examples/good_fileproc.sh](../copilot-examples/good_fileproc.sh)
  - Bad:  [.github/copilot-examples/bad_violations.sh](../copilot-examples/bad_violations.sh)
