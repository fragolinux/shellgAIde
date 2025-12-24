# Versioning

shellgAIde uses **Semantic Versioning**.

## Version sources

- `VERSION` is the single source of truth (for banners/prompt/docs).
- Git tags should be `vX.Y.Z` and match `VERSION`.

## Releases

- Create an **annotated tag** (example: `v1.0.0`) and push it.
- A GitHub Actions workflow will automatically:
  - create a GitHub Release
  - attach a source archive (`shellgAIde-vX.Y.Z.zip`)

## Bumping

Update `VERSION`, then update `CHANGELOG.md`, then tag:

```bash
git commit -am "chore(release): vX.Y.Z"
git tag -a vX.Y.Z -m "vX.Y.Z"
git push origin main --tags
```
