# shellgAIde

**shellgAIde** is a deterministic, GNU-first shell scripting toolchain inspired by the **Google Shell Style Guide**.

**Name meaning:** **shell** + **gAIde**  
- **g** → Google (explicit nod to Google’s Shell Style Guide)  
- **AI** → the intended workflow is “generate / refactor with AI, then validate deterministically”  
- **de** → **deterministic environment** (same rules, same tools, same results across machines)

## TL;DR

```bash
# 1) One-time per machine (interactive)
make setup

# 2) Daily workflow (recommended)
make shell     # enter a toolchain bash with GNU-first PATH + a clear prompt prefix
make ci        # check + lint + tests

# CI runners (non-interactive; installs deps + runs checks)
make ci-only
```

## What this repo gives you

- A **GNU-first baseline** (especially for macOS): consistent `sed/grep/find/xargs/date` behavior.
- A **lint gate** for shell scripts:
  - structure rules aligned to a “ShellgAIde” style (inspired by Google Shell Style Guide),
  - ShellCheck,
  - shfmt diff (format drift is shown as a diff).
- A **toolchain shell** (`make shell`) that makes it obvious when you are inside the toolchain and prevents accidental nesting.
- A **CI-safe entrypoint** (`make ci-only`) that installs dependencies and runs the same checks as local.

## Quickstart

### macOS (recommended workflow)

```bash
make setup
make shell
make ci
```

### Linux (Ubuntu/Debian)

```bash
make setup
make shell
make ci
```

If you prefer to stay in your current shell instead of opening the toolchain subshell:

```bash
source .toolchain/env.sh
make ci
```

## The basic commands

- `make setup`  
  Installs required tools (Homebrew on macOS, apt best-effort on Linux) and generates `.toolchain/env.sh`.  
  Use `YES=1` to auto-consent:
  ```bash
  make setup YES=1
  ```

- `make shell`  
  Opens an interactive **bash** with the toolchain environment loaded (GNU-first PATH) and a clear prompt prefix like:
  ```
  [toolchain 1.0.0] user@host:repo$
  ```

- `make check`  
  Verifies the machine is aligned (no changes).

- `make lint`  
  Lints scripts (ShellCheck + shfmt diff + structure rules).  
  Defaults to `LINT_PATH=.`. Override with a single file or directory:
  ```bash
  make lint
  make lint LINT_PATH=path/to/script.sh
  make lint LINT_PATH=path/to/dir
  ```

- `make test`  
  Runs bats tests.

- `make ci`  
  Runs `check` + `lint` + `test`.  
  **Note:** on macOS, run this *inside* the toolchain (`make shell`) unless you already sourced `.toolchain/env.sh`.

- `make ci-only`  
  CI entrypoint: installs prerequisites + generates `.toolchain/env.sh` + runs the checks.  
  Intended for GitHub Actions runners and other unattended environments.

## AI-assisted script creation / refactoring

The workflow is:

1) **Use an AI** to create or refactor a script using the “ShellgAIde rules”  
2) **Validate** locally using this toolchain (lint + tests)

### The prompt to use

The authoritative prompt is in **PROMPT_SYSTEM.md**.  
You can copy/paste it as “system instructions” (or equivalent) for your AI agent.

### ChatGPT (manual workflow)

1. Open **PROMPT_SYSTEM.md** and paste it into your chat as the “system” or “instructions” message (or just paste at the top and say “treat this as system instructions”).  
2. Provide either:
   - “Create a new script that …” or
   - “Refactor this existing script to comply with ShellgAIde style” (and paste the script).
3. Ask for output as a **single file** (no ellipses, no truncation).

Then validate:

```bash
make setup
make shell
make lint LINT_PATH=./path/to/your_script.sh
make ci
```

### GitHub Copilot (VS Code)

This repo includes **.github/copilot-instructions.md**.  
Copilot Chat will use it automatically in most setups.

Suggested workflow:

1. Keep your script open in the editor.
2. Ask Copilot Chat to “refactor this file to comply with ShellgAIde (Google Shell Style)”.
3. Run:
   ```bash
   make shell
   make lint LINT_PATH=path/to/file.sh
   ```

### Codex / other agents

Wherever the agent allows “project instructions” / “system prompt”:

- paste the content of **PROMPT_SYSTEM.md**
- keep output constrained to *one bash file*
- run the same validation steps (`make lint`, `make ci`)

## Optional: save lint artifacts instead of staring at huge diffs

The linter supports writing artifacts to a reports folder (useful in CI logs or to compare outputs):

- `LINT_ARTIFACTS=1` to create a report directory under `.reports/`
- `LINT_SNAPSHOT=1` to also keep “snapshot” copies

Example:

```bash
make lint LINT_ARTIFACTS=1
make lint LINT_ARTIFACTS=1 LINT_SNAPSHOT=1
```

## GitHub Actions

This repo ships with:

- CI workflow (Linux + macOS)
- GitHub Pages deployment for docs
- Release workflow (tag → GitHub Release)

## License

MIT (see LICENSE).
