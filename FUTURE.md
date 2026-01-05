# Future Improvements & Design Notes

This document collects **intentional future evolutions**, open design topics,
and features that are **useful but intentionally not yet implemented**.

Nothing here is required to use the toolchain today.
Everything here is evaluated against the core principles:

- GNU-first userland
- automation over discipline
- reproducibility
- CI enforcement
- no feature added “just because it can be done”

---

## 1. Docker as an Optional Execution Environment

### Context
The team uses:
- Windows + WSL (x86_64)
- macOS (Apple Silicon, arm64)
- DevContainers running on Docker (WSL + Docker Desktop)

This heterogeneity makes **environment drift** a real risk.

### When Docker *is* useful here

Docker provides real value if used as:

- an **optional execution mode** for the toolchain
- a **golden, reproducible environment**
- a way to run `make ci` with **zero local installation**

Typical use case:
```bash
docker run --rm -v "$PWD:/work" IMAGE make ci PATH=/work
```

This is especially valuable for:
- onboarding developers quickly
- locked-down machines
- CI and ephemeral environments
- debugging environment-related failures

### When Docker should NOT replace local usage

Docker must **not**:
- replace the local bootstrap entirely
- hide GNU/PATH issues on macOS forever
- become the only supported way to run the toolchain

Local bootstrap remains important to catch:
- PATH misconfiguration
- accidental reliance on BSD tools
- differences between container and real host

### Decision rule
Docker is justified **only if** it:
- reduces onboarding friction
- improves reproducibility
- does not weaken enforcement

---

## 2. Container Support Scope (If Implemented)

If Docker support is added, choose **one** scope:

### Option A — CI / Runner Image (recommended)
- Purpose: run `make ci`
- Minimal image:
  - GNU userland
  - bash 5.x
  - shellcheck, shfmt, bats
  - this toolchain
- No interactive development assumptions

### Option B — DevContainer Base Image
- Purpose: interactive development
- More maintenance
- Overlaps with existing devcontainer setups

### Mandatory constraints
- Multi-architecture manifest: `linux/amd64` + `linux/arm64`
- Single tag per version (no arch-specific tags)
- Built via GitHub Actions + Buildx on tag push

---

## 3. DevContainers Integration

If DevContainers are added:
- Provide a reference `.devcontainer/` configuration
- Base on Debian/Ubuntu
- Run `make check` in `postCreateCommand`
- Keep CI on Linux + macOS runners (containers are not the only source of truth)

---

## 4. Machine-Readable Reports

### Potential future needs
- JSON or SARIF output for lint
- JUnit XML from Bats
- Console output:
  - UTF-8 icons when supported
  - ASCII fallback otherwise

All outputs must be:
- optional
- opt-in
- never weaken enforcement

---

## 5. Pre-Commit Enforcement

Possible future checks:
- block commit if `.toolchain/env.sh` is not sourced
- block commit if `make ci` fails

Can be implemented via:
- `pre-commit` framework
- or a simple git hook

---

## 6. Signed Releases

### Goal
Allow consumers to verify authenticity.

Options:
- GPG-signed checksums
- Sigstore / Cosign

---

## 7. Policy-Aware Linting

Different rule sets per directory, e.g.:
- `scripts/ci/`: stricter rules
- `scripts/dev/`: relaxed logging

Still enforced by the same engine.

---

## 8. Repository Badges

Recommended badges:
- CI status (Linux + macOS)
- Latest release
- License
- ShellCheck compliance

Badges improve trust and visibility without affecting behavior.

---

## 9. Direnv Auto-Load (Optional)

### Context
Some contributors prefer automatic activation of the GNU-first environment
without running `source .toolchain/env.sh` manually.

### Proposed approach
- Provide an optional `.envrc` that sources `.toolchain/env.sh`.
- Document `direnv allow` as a one-time enablement step.

### Notes
- Keep `.envrc` under version control only if the whole team wants it.
- This remains opt-in; it must not replace explicit `make shell` usage.

---

This document is intentionally separate from the README.
The README describes **how to use the toolchain today**.
This file describes **how it may evolve tomorrow**.

---

## 10. DevContainer Toolchain Mounts (Read-Only)

### Context
Multiple repositories already use DevContainers (mixed stacks: Java, Node, Helm,
and infra code). Those repos must keep their own Commitizen setup, Jira-linked
plugins, and release/bump scripts unchanged.

### Goal
Expose only the toolchain (prompt + agent config) across DevContainers without
copying files into each repo and without modifying their commit workflows.

### Proposed approach
- Mount this repo into each DevContainer **read-only** (e.g., `/opt/shellgaide`).
- Export `PATH` and toolchain config vars from the container config.
- Make prompt activation **opt-in** via an explicit env flag.
- Provide wrapper commands that set default paths (no manual `LINT_PATH`).

### Command and Makefile ergonomics
- Prefer wrapper commands in `bin/` that set:
  - `SHELLGAIDE_HOME`
  - `SHELLGAIDE_CONFIG`
  - `LINT_PATH`
- Provide a `shellgaide-make` wrapper that runs:
  - `make -C "$SHELLGAIDE_HOME" <target>`
  - avoids touching host repo Makefiles

### Non-goals / constraints
- Do not alter Commitizen (`cz`) behavior in host repos.
- Do not move or duplicate release/bump scripts into other repos.
- No changes to repo prompts unless explicitly enabled.

### Variants
- Use `docker-compose.override.yml` or a DevContainer feature to keep base
  configs unchanged.
- Optionally pin the mounted toolchain by tag/commit if stability is required.
