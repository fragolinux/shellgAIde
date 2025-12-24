# Versioning

shellgAIde uses **Semantic Versioning**.

## Version sources

- `VERSION` is the single source of truth (for banners/prompt/docs).
- `config/toolchain.conf` mirrors `VERSION` for scripts that source config.
- Git tags should be `vX.Y.Z` and match `VERSION`.

## Releases

- Create an **annotated tag** (example: `v1.0.0`) and push it.
- A GitHub Actions workflow will automatically:
  - create a GitHub Release
  - attach a source archive (`shellgAIde-vX.Y.Z.zip`)

## Commitizen (Python) setup

### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y pipx
pipx ensurepath
pipx install commitizen
```

### macOS

```bash
brew install python pipx
pipx ensurepath
pipx install commitizen
```

## Bumping (with Commitizen)

Commitizen keeps `VERSION`, `config/toolchain.conf`, and `CHANGELOG.md` aligned.

Minimal commit flow (single release commit):

```bash
cz bump --changelog
git push origin main --tags
```

If you need to review before pushing:

```bash
cz bump --changelog
git show
git push origin main --tags
```
