# shellgAIde Copilot Examples

Reference scripts demonstrating GNU-first Bash patterns and common violations.

## Good Examples

### [good_minimal.sh](good_minimal.sh)
Minimal compliant script showing:
- Required structure (shebang, header, `set -euo pipefail`, `main()`)
- Proper naming (`UPPER_CASE` globals, `lower_case` locals/functions)
- Safe quoting and `die()` helper
- Simple argument validation

### [good_fileproc.sh](good_fileproc.sh)
Complete script with:
- Command-line option parsing (flags, arguments)
- File validation and processing
- Verbose logging pattern
- GNU tool usage (sed)
- Proper error handling

## Bad Examples (Anti-patterns)

### [bad_violations.sh](bad_violations.sh)
Common violations to avoid:
- Missing header markers (Description/Usage/Dependencies)
- Missing `set -euo pipefail`
- Using `[ ]` instead of `[[ ]]`
- Unquoted variables
- Backticks instead of `$()`
- Parsing `ls` output
- Using `function` keyword
- Missing `main()` structure
- Non-readonly globals

## Usage

When asking Copilot to generate/refactor scripts, refer to these examples:

```
"Create a script like good_minimal.sh that processes directories"
"Refactor this script to avoid patterns in bad_violations.sh"
"Generate a file processor similar to good_fileproc.sh"
```

These examples are validated by the toolchain:
```bash
make lint LINT_PATH=.github/copilot-examples/good*.sh
```

**Note:** Files matching `bad_*.sh` are intentionally excluded from automated linting to allow documenting anti-patterns without failing CI. The naming convention `bad_*.sh` signals "intentional violations for documentation purposes".
