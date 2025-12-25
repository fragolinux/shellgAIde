# Changelog

## v1.0.5 (2025-12-25)

### CI

- **docs**: silence macos brew warning; publish ai-config page

## v1.0.4 (2025-12-25)

### Docs

- **agents**: consolidate ai agent config

### Chore

- **release**: add release helper scripts

## v1.0.3 (2025-12-25)

### CI

- **commitizen**: include ci/docs in changelog and bump rules
- **release**: add release artifacts and checksums

## v1.0.2 (2025-12-25)

- **release**: add commitizen setup and update release docs

## v1.0.1 (2025-12-24)

### Docs & GitHub Pages

- README expanded with a TL;DR and an explanation of the project name (**shellgAIde**).
- Added common GitHub badges (CI, Pages, release, license).
- GitHub Pages is now generated from `README.md`, keeping the website and README aligned.

### Release notes automation

- Release workflow now extracts the matching section from `CHANGELOG.md` and uses it as the GitHub Release notes.

### Fix

- **release**: generate notes from CHANGELOG
- **release**: extract notes from CHANGELOG reliably

## v1.0.0 (2025-12-24)

### Initial release

This initial public release includes:

- GNU-first shell toolchain (macOS & Linux)
- Deterministic bootstrap and alignment (`make setup` / `make align`)
- Interactive, clearly-marked toolchain shell (`make shell`)
- Strict linting (ShellCheck, shfmt diff, structure checks)
- Snapshot-capable lint workflow
- Bats-based test suite
- Makefile-driven UX
- CI-ready non-interactive gate (`make ci-only`)
