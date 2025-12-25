---
layout: default
title: AI Agent Configuration
---

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

## Manual setup (full instructions)

### 1) ChatGPT

Recommended approach:
1. Create a ChatGPT Project (or use Custom Instructions) and paste the full
   content of `PROMPT_SYSTEM.md` into the project instructions.
2. Ask for either:
   - a new script ("Create a new script that does X"), or
   - a refactor ("Refactor this script to conform to the system prompt;
     preserve behavior").

When refactoring, include:
- The current script (full text).
- Constraints (what must not change).
- Any expected I/O examples (flags, env vars, exit codes).

### 2) OpenAI Codex (CLI)

Codex CLI supports repository instructions via `AGENTS.md`.
Typical flow:
1. Start Codex in the repo root.
2. Run `/init` to create `AGENTS.md`.
3. Paste the full content of `PROMPT_SYSTEM.md` into `AGENTS.md` (or summarize
   while keeping the non-negotiable rules).
4. Ask Codex to create/refactor the script, then review and apply diffs.

### 2b) OpenAI Codex (VS Code extension)

The VS Code Codex extension also supports repository instructions.
Typical flow:
1. Ensure `AGENTS.md` exists in the repo root.
2. Paste the full content of `PROMPT_SYSTEM.md` into `AGENTS.md` (or a concise
   but complete adaptation).
3. Reload the VS Code window or restart the Codex session.
4. Use Codex Chat to create/refactor scripts; the instructions are applied
   automatically.

### 3) GitHub Copilot (VS Code / Visual Studio / JetBrains)

Copilot supports repository custom instructions.
Typical flow:
1. Create `.github/copilot-instructions.md` in your target repo.
2. Paste the full content of `PROMPT_SYSTEM.md` into that file (or a concise
   but complete adaptation).
3. Use Copilot Chat to create/refactor scripts with the instructions applied
   automatically.

Note: Copilot instruction support may vary by IDE and requires the feature to
be enabled.

### 4) Google Gemini (Gemini CLI)

Recommended approach:
1. Add a `GEMINI.md` file in your repo root (or parent dirs).
2. Reference `PROMPT_SYSTEM.md` with a relative `@PROMPT_SYSTEM.md`.

Notes:
- Use `/memory show` to inspect, `/memory refresh` to reload, and
  `/memory add <text>` to append to `~/.gemini/GEMINI.md`.
- You can import other files inside `GEMINI.md` with `@file.md` (relative or
  absolute paths).
- You can change the filename via `settings.json` using `context.fileName`.
- Reference: https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/gemini-md.md

### 5) Anthropic Claude (Claude Code)

Recommended approach:
1. Add a `CLAUDE.md` file in your repo root (or parent dirs).
2. Reference `PROMPT_SYSTEM.md` with a relative `@PROMPT_SYSTEM.md`.
3. Optionally run `/init` in Claude Code to generate a starter `CLAUDE.md`,
   then review and refine it to match your real workflow.

Notes:
- `CLAUDE.md` is loaded automatically by Claude Code and becomes part of the
  system prompt for every session.
- You can place `CLAUDE.md` in a parent directory for monorepos or in your home
  folder to apply it to all projects.
- Keep it concise and avoid secrets; treat it like shareable documentation.
- Reference: https://claude.com/blog/using-claude-md-files

## Verify output with this toolchain

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
