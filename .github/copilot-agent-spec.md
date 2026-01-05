# shellgAIde Custom Agent Specification

This document describes the custom agent architecture for GitHub Copilot and other AI assistants.

## Architecture: Single Source of Truth

```
PROMPT_SYSTEM.md (canonical rules, ~200 lines)
    ↓ referenced by
.github/copilot-instructions.md (agent definition + quick ref)
    ↓ examples in
.github/copilot-examples/ (reference scripts: good/bad patterns)
```

**Design principle:** PROMPT_SYSTEM.md contains all technical rules. Agent files reference it, not duplicate it.

---

## Agent Definition Structure

### File: `.github/copilot-instructions.md`

#### 1. Frontmatter (YAML)

```yaml
---
agent:
  name: shellgAIde GNU-First Bash Agent
  version: 1.0.0
  description: Senior Bash engineer for GNU-first shell scripting
  triggers:
    file_patterns: ["*.sh", "*.bash"]
    directories: ["bin/", "lib/", "scripts/"]
    keywords: ["bash", "shell", "script", "gnu"]
  capabilities:
    - generate_new_scripts
    - refactor_existing_scripts
    - validate_compliance
    - explain_violations
    - suggest_improvements
  source: ../PROMPT_SYSTEM.md
---
```

**Fields:**
- `name`: Human-readable agent identifier
- `version`: Semantic version (synced with toolchain VERSION file)
- `description`: One-line role statement
- `triggers`: When the agent activates automatically
  - `file_patterns`: Glob patterns for file matching
  - `directories`: Project subdirectories
  - `keywords`: Terms in user queries
- `capabilities`: What the agent can do (verbs)
- `source`: Path to canonical rule document

#### 2. Quick Reference

Compact summary of:
- Core requirements (Bash version, GNU tools, structure)
- Naming conventions
- Forbidden patterns
- Toolchain integration points

**Purpose:** Fast lookup without reading full PROMPT_SYSTEM.md

#### 3. Agent Behavior

Describes how the agent responds to different request types:
- New script generation
- Refactoring existing code
- Validation/linting
- Output format preferences

#### 4. Reference to Authoritative Rules

Explicit pointer to PROMPT_SYSTEM.md with section index.

**Critical:** States that PROMPT_SYSTEM.md is the single source of truth.

---

## Example Repository

### File: `.github/copilot-examples/`

Reference scripts demonstrating patterns:

| File | Purpose | Validates |
|------|---------|-----------|
| `good_minimal.sh` | Simplest compliant script | Structure, safety, naming |
| `good_fileproc.sh` | Complete real-world example | Arg parsing, file ops, logging |
| `bad_violations.sh` | Anti-patterns (intentional) | What NOT to do |
| `README.md` | Example index and usage | How to reference examples |

**Integration:**
- Good examples must pass `make lint`
- Bad examples use `bad_*.sh` naming convention and are automatically excluded from linting
- Users can reference examples in prompts: "Create a script like good_fileproc.sh"

**Naming convention:** Files matching `bad_*.sh` are skipped by the linter to allow documenting anti-patterns without failing CI.

---

## Versioning Strategy

### Version Sync
Agent version (`copilot-instructions.md`) follows toolchain version (`VERSION` file).

### Version Bump Triggers
Increment version when:
- New mandatory rules added to PROMPT_SYSTEM.md
- Capabilities added/removed
- Breaking changes in script structure requirements

### Changelog
Document agent changes in `CHANGELOG.md` under "Agent" subsection.

---

## Multi-IDE Support

### GitHub Copilot
- **Location:** `.github/copilot-instructions.md`
- **Activation:** Automatic (feature must be enabled in IDE settings)
- **Support:** VS Code, Visual Studio, JetBrains
- **Reload:** Restart IDE or reload window after changes

### OpenAI Codex CLI
- **Location:** `AGENTS.md` (root)
- **Activation:** `/init` command
- **Format:** Markdown with embedded prompt or reference

### Gemini CLI / Claude Code
- **Location:** `.clinerules` / `.claude`
- **Format:** `@PROMPT_SYSTEM.md` import syntax
- **Note:** File-specific conventions vary

---

## Testing the Agent

### 1. Validation (static)
```bash
# Lint good examples
make lint LINT_PATH=.github/copilot-examples/good*.sh

# Verify bad examples fail
./bin/lint.sh .github/copilot-examples/bad_violations.sh
# (should exit non-zero)
```

### 2. Integration (interactive)
```bash
# Open Copilot Chat in VS Code
# Test prompts:
"Create a new script that processes log files"
"Refactor this script to be compliant"
"Explain violations in this code"

# Verify generated scripts pass CI
make ci
```

### 3. Regression (CI)
Add test case to `tests/`:
```bash
# tests/agent_examples.bats
@test "good examples pass lint" {
  run make lint LINT_PATH=.github/copilot-examples/good*.sh
  [ "$status" -eq 0 ]
}
```

---

## Extending the Agent

### Adding New Capabilities

1. Update `capabilities` list in frontmatter
2. Document behavior in "Agent Behavior" section
3. Add example to `copilot-examples/` if relevant
4. Test with Copilot Chat
5. Bump agent version

### Adding New Rules

1. Update `PROMPT_SYSTEM.md` (authoritative)
2. Add quick reference entry in `copilot-instructions.md` if critical
3. Create example demonstrating new rule
4. Update `CHANGELOG.md`
5. Bump version (major if breaking, minor if additive)

---

## Limitations & Known Issues

1. **Frontmatter parsing:** GitHub Copilot may not parse YAML frontmatter. Metadata is primarily documentation for humans. The agent relies on the markdown content.

2. **Trigger reliability:** `file_patterns` and `keywords` are hints, not guarantees. Agent may activate on any query in the workspace.

3. **No dynamic loading:** Changes require IDE reload. No hot-reload capability.

4. **IDE variance:** Support and behavior differ across VS Code, JetBrains, Visual Studio.

5. **No validation API:** Cannot programmatically verify agent is loaded or active.

---

## References

- [GitHub Copilot Custom Instructions](https://docs.github.com/en/copilot) (official docs)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck Wiki](https://www.shellcheck.net/wiki/)
- [shellgAIde PROMPT_SYSTEM.md](../PROMPT_SYSTEM.md)
