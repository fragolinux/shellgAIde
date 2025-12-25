# shellgAIde

Deterministic **GNU-first** shell toolchain inspired by the Google Shell Style Guide, with CI-safe workflows and an interactive toolchain shell.

Reference: [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).

[![CI](https://github.com/fragolinux/shellgAIde/actions/workflows/ci.yml/badge.svg)](https://github.com/fragolinux/shellgAIde/actions/workflows/ci.yml)
[![Pages](https://github.com/fragolinux/shellgAIde/actions/workflows/pages.yml/badge.svg)](https://github.com/fragolinux/shellgAIde/actions/workflows/pages.yml)
[![Release](https://img.shields.io/github/v/release/fragolinux/shellgAIde?sort=semver)](https://github.com/fragolinux/shellgAIde/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-informational.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/language-shell-9cf)](#)

## Why the name?

shellgAIde is a pun that sounds like **shellguide**:

- **shell**: the domain (bash, portable scripts)
- **gAIde**: a “guide” powered by **AI**, inspired by the Google Shell Style Guide
  - **G** = Google (explicitly referencing the style guide)
  - **AI** = the assistant that generates scripts
  - **de** = *deterministic environment* (the key promise of this repo)

## TL;DR

### First time (local)

```bash
make setup          # installs deps (apt/brew) and writes .toolchain/env.sh
make shell          # opens the toolchain shell (prompt shows [toolchain <version>])
make ci             # check + lint + tests (inside the toolchain shell)
```

### Daily usage

```bash
make shell
make ci
```

### CI (GitHub Actions runners)

```bash
make ci-only        # non-interactive, installs deps and runs checks
```

> `YES=1` is only meant for **setup/align** (to auto-consent prompts). `ci-only` is designed to be non-interactive and should not require `YES=1`.

> Note: `make` is configured with `--no-print-directory` for uniform output across Linux and macOS.
> Tip: `make shell` opens an interactive Bash subshell with a prompt prefix like `[toolchain x.y.z]` so you always know you're inside the toolchain environment.



## When to use `make shell` vs `source .toolchain/env.sh`

### `make shell` (recommended for humans)
Use this when you want a **safe, explicit toolchain context** with a clear prompt marker:

- You always see: `[toolchain x.y.z] ...`
- `exit` always returns you to your original shell (no ambiguity)
- No need to remember anything else after setup

Typical flow:
```bash
make setup
make shell
make ci
```

### `source .toolchain/env.sh` (advanced / integration use)
Use this when you specifically need the GNU-first PATH **in your current shell session** (no subshell), for example:

- running `sed/grep/date/find` manually in your current terminal on macOS
- IDE tasks / VS Code tasks that execute in your existing shell session
- scripting in your own shell where you don't want to open a separate Bash

Example:
```bash
make setup
source .toolchain/env.sh
make ci
```

> Note: `source` modifies only the current shell session; open a new terminal and you'd need to source again.
> On macOS, you must source the environment after `make align` before running `make check` (unless you use `make shell`).


## Applying the system prompt (AI agents)

See [AI agent configuration](docs/ai-config.md) for the minimal file locations
and contents used by each agent.
For the published page, use:
[https://fragolinux.github.io/shellgAIde/ai-config.html](https://fragolinux.github.io/shellgAIde/ai-config.html).

### Verify output with this toolchain

After generating/refactoring a script (locally):
```bash
make setup
# then inside the toolchain shell:
make lint
make test
make ci
```

For a single script:
```bash
make shell
# then:
./bin/lint.sh path/to/script.sh
```

## Core Principles

1. **No BSD/GNU compromises**
   - Scripts assume GNU tools (`grep`, `sed`, `date`, `find`, `xargs`).
   - macOS must be aligned via bootstrap.
   - Scripts do NOT implement compatibility branches.

2. **Fail fast**
   - If the environment is not aligned, scripts must fail with actionable instructions.

3. **One mental entrypoint**
   - Everything is driven via `make`.

4. **Automation > discipline**
   - Rules are enforced by tooling, not by memory.

---

## Toolchain Layout

```
.
├── bin/
│   ├── bootstrap.sh   # environment check + alignment
│   ├── ci_only.sh     # unattended CI gate (align + check + lint + test)
│   ├── lint.sh        # shell linting & structural enforcement
│   ├── shell.sh       # interactive toolchain shell wrapper
│   └── test.sh        # bats test runner
├── lib/
│   └── common.sh      # shared helpers
├── config/
│   └── toolchain.conf # version + policy
├── tests/
│   ├── fixtures/      # known-good / known-bad samples
│   └── *.bats         # regression tests
├── PROMPT_SYSTEM.md   # system prompt for AI tools
└── Makefile
```

---

## Quick Start

### 1. Inspect available commands
```bash
make help
```

### 2. Check machine alignment (safe, read-only)
```bash
make check
```

- Returns `0` if aligned
- Returns `10` if not aligned (expected on macOS initially)

### 3. Align machine (explicit consent required)
```bash
make align
```

This will:
- Install GNU tools (macOS via Homebrew)
- Install Bash 5.x, ShellCheck, shfmt, bats
- Generate `.toolchain/env.sh`

⚠️ You MUST source `.toolchain/env.sh` to activate GNU-first PATH.

---

## Daily Usage

### Lint scripts
```bash
make lint LINT_PATH=.
make lint LINT_PATH=scripts/
```

What lint does:
- Verifies Google-style structure (shebang, header, main)
- Runs ShellCheck (hard gate)
- Runs shfmt in diff mode
- Fails on any violation

### Run tests
```bash
make test
```

### CI gate
```bash
make ci LINT_PATH=.
```

Equivalent to:
1. `bootstrap check`
2. `lint`
3. `test`

---

## Writing New Scripts

All scripts MUST:

- Use GNU tools
- Use Bash >= 5.x
- Start with the standard header
- Use `main()`
- End with `main "$@"`

If a script passes:
```bash
make ci
```
…it is considered **production-acceptable**.

---

## Versioning & Upgrades

- Toolchain versions are explicit (`toolchain.conf`).
- New versions should:
  - Extend rules, never weaken them
  - Add tests to prevent regressions
  - Bump version and regenerate zip

---

## Philosophy

If a script:
- works on one machine but not another
- relies on implicit PATH behavior
- requires human memory to stay correct

…it is considered **broken by design**.

This toolchain exists to prevent that class of failure.


## GitHub Actions (unattended)

Use:

```bash
make ci-only
```

This target is designed for CI runners and will perform unattended alignment on macOS.


## GitHub Pages

This repo includes a Pages workflow that publishes `docs/` to GitHub Pages.

- Enable Pages in repo settings (Actions-based deployment or Pages from workflow).
- After pushing to `main`, the site will be available under `https://<owner>.github.io/<repo>/`.



## Shell compatibility note (bash/zsh)

`source .toolchain/env.sh` is intended to be safe in interactive shells (bash and zsh). The generated env file does **not** enable shell options like `nounset` to avoid breaking zsh prompts.

If you prefer not to modify your current shell state, use:

```bash
make shell
```



## Troubleshooting

### `env: bash: No such file or directory`
This means your `PATH` does not contain a `bash` executable when scripts run via `#!/usr/bin/env bash`.

Fix:
1. Run `make align`
2. Activate the environment:
   ```bash
   source .toolchain/env.sh
   ```
3. Verify:
   ```bash
   command -v bash
   bash --version | head -n 1
   ```
On macOS, the toolchain expects **Homebrew Bash (>= 5.x)** to be found first on PATH.


### Note: running via Make

Make targets invoke toolchain scripts via `bash` explicitly to avoid any edge cases with shebang resolution (`#!/usr/bin/env bash`) in unusual PATH environments.


### Lint scope

By default, linting ignores the generated `.toolchain/` directory. Use `LINT_PATH=...` to lint specific locations.

## Lint options (artifacts and snapshots)

By default, `make lint` checks the whole repository (`LINT_PATH` defaults to `.`). Override it for a single file or directory:

```bash
make lint LINT_PATH=path/to/script.sh
```

### Artifact mode (reduce terminal noise)

If you want to avoid large terminal diffs, enable artifact mode:

```bash
make lint LINT_ARTIFACTS=1
```

This saves outputs under `.toolchain/reports/lint-<timestamp>/` (gitignored), including:
- `shellcheck.txt`
- `shfmt.patch`
- `snapshot.patch` (if snapshot mode is enabled)

### Snapshot mode (formatted baseline, no working-tree changes)

If you want a formatted baseline without touching your working tree:

```bash
make lint LINT_SNAPSHOT=1
```

This creates a copy under `.toolchain/snapshots/lint-<timestamp>/` and runs lint against the snapshot.
Combine with artifact mode to produce a patch you can apply:

```bash
make lint LINT_SNAPSHOT=1 LINT_ARTIFACTS=1
```


> Note: `make shell` shows a `[toolchain x.y.z]` prompt prefix and will not start a nested toolchain shell if you're already inside one (`TOOLCHAIN_SHELL=1`).
