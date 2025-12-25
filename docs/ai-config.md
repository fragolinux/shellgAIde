# AI Agent Configuration

This repo keeps a single canonical prompt in `PROMPT_SYSTEM.md` and all agent
files reference it using a relative path.

## Files and minimal contents

### `GEMINI.md` (repo root or subdir)
```markdown
# shellgAIde
@PROMPT_SYSTEM.md
```

### `CLAUDE.md` (repo root or subdir)
```markdown
# shellgAIde
@PROMPT_SYSTEM.md
```

### `AGENTS.md` (repo root, for Codex/Copilot)
```markdown
# shellgAIde - GNU-first Shell Toolchain
See full system prompt: [PROMPT_SYSTEM.md](PROMPT_SYSTEM.md)

Core rules: Google Shell Style Guide, GNU tools (grep/sed/date), Bash 5+,
main() structure, CI-safe.
```

### `.github/copilot-instructions.md` (subdir)
```markdown
# shellgAIde Copilot
Follow [../PROMPT_SYSTEM.md](../PROMPT_SYSTEM.md): GNU-first toolchain, Google
Shell Style, main() structure.
```

## Notes on paths

- Use a relative `@PROMPT_SYSTEM.md` from the file location.
- For `.github/copilot-instructions.md`, go up one level with `../`.
