# Changelog

## [1.0.0] - 2025-12-24

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
