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

## 1. Automated Releases & Versioned Artifacts

### Goal
Produce **reproducible, traceable, verifiable release artifacts** with zero manual steps.

### Recommended approach
- Git tags are the **single source of truth** (`vMAJOR.MINOR.PATCH`).
- On tag push:
  - run full CI (Linux + macOS)
  - build release archive:
    - `gnu-first-shell-toolchain-vX.Y.Z-YYYYMMDD.zip`
  - generate checksums (`SHA256SUMS`)
  - optionally sign checksums (GPG or Sigstore)
  - attach artifacts to a GitHub Release

### Why this matters
- No “hand-built” releases
- Perfect traceability from commit → tag → artifact
- Easy rollback and auditing

---

## 2. Docker as an Optional Execution Environment

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

## 3. Multi-Architecture Docker Images (If Implemented)

If a Docker image is introduced, it MUST:

- be built as a **multi-architecture manifest**
- support at least:
  - `linux/amd64`
  - `linux/arm64`
- expose **a single tag per version**
  - no arch-specific tags required by users

### Recommended implementation
- Use GitHub Actions + Docker Buildx
- Build on tag push:
  ```bash
  docker buildx build     --platform linux/amd64,linux/arm64     --push     -t ghcr.io/<org>/<repo>:vX.Y.Z
  ```

### Why this is mandatory
- macOS (arm64) and WSL (amd64) must behave identically
- users should never care about architecture details
- avoids tag explosion and human error

---

## 4. Docker Image Scope Options

If Docker support is added, choose ONE clearly:

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

Initial recommendation: **Option A only**.

---

## 5. DevContainers Integration

### Why it fits well
- Containers already guarantee GNU tools
- Bash versioning is trivial
- Reproducibility is high

### Suggested improvements
- Provide a reference `.devcontainer/` configuration
- Base on Debian/Ubuntu
- Run `make check` in `postCreateCommand`

### Caution
CI must still run on:
- Linux runners
- macOS runners

Containers should not become the sole source of truth.

---

## 6. Machine-Readable Reports

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

## 7. Pre-Commit Enforcement

Possible future checks:
- block commit if `.toolchain/env.sh` is not sourced
- block commit if `make ci` fails

Can be implemented via:
- `pre-commit` framework
- or a simple git hook

---

## 8. Signed Releases

### Goal
Allow consumers to verify authenticity.

Options:
- GPG-signed checksums
- Sigstore / Cosign

---

## 9. Policy-Aware Linting

Different rule sets per directory, e.g.:
- `scripts/ci/`: stricter rules
- `scripts/dev/`: relaxed logging

Still enforced by the same engine.

---

## 10. Repository Badges

Recommended badges:
- CI status (Linux + macOS)
- Latest release
- License
- ShellCheck compliance

Badges improve trust and visibility without affecting behavior.

---

This document is intentionally separate from the README.
The README describes **how to use the toolchain today**.
This file describes **how it may evolve tomorrow**.
