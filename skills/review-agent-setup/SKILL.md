---
name: review-agent-setup
description: >-
  Audit the AI coding setup — skills, rules, journal, agent transcripts, and
  MCP config — to find what's working, what's unused, and what's missing.
  Suggests additions, modifications, and cleanup. Works for any supported
  IDE (Cursor, Claude Code, Codex CLI, Gemini CLI). Use when the user says
  "review my setup", "audit my skills", "review agent config", "review cursor
  config", "review claude config", "what skills should I add", "how is my
  setup working", or "optimize my setup".
---

# Review Agent Setup

Perform a comprehensive audit of the user's AI coding configuration by analyzing what exists, how it's actually being used, and where the gaps are.

## Workflow

### 1. Detect installed IDEs

Check which AI coding IDEs are installed by looking for their home directories. Each IDE that exists is a distinct surface area to audit.

| IDE | Home directory | Skills | Agents | Rules |
|---|---|---|---|---|
| Cursor | `~/.cursor/` | `skills/` | `agents/` | `rules/*.mdc` |
| Claude Code | `~/.claude/` | `skills/` | `agents/` | `rules/` + `CLAUDE.md` |
| Codex CLI | `~/.codex/` | `skills/` | (n/a) | `AGENTS.md` |
| Gemini CLI | `~/.gemini/` | `skills/` | (n/a) | `GEMINI.md` |

If only one IDE is installed, focus the audit there. If multiple are installed, audit each in turn but flag duplicates and divergences (a skill in only some IDEs, a rule that exists only in `~/.cursor/rules/` but should be in the global rules file too, etc.).

### 2. Gather inventory (parallel)

Launch parallel explore agents to collect:

**Skills inventory** — Read every `SKILL.md` in:
- `~/.cursor/skills/`, `~/.claude/skills/`, `~/.codex/skills/`, `~/.gemini/skills/` (whichever exist; many will be symlinks pointing at the same source)
- `.cursor/skills/` or `.claude/skills/` in any workspace repos (project-level skills)

For each: name, description, line count, supporting files. De-duplicate by following symlinks to the canonical source.

**Rules inventory** — Read every rule:
- Cursor: every `.mdc` in `~/.cursor/rules/`
- Claude Code: every `.mdc` in `~/.claude/rules/` (Claude Code reads `.mdc` files; agent-config-public's install.sh symlinks the same `rules/` directory it uses for Cursor), plus the agent-config-public managed section in `~/.claude/CLAUDE.md`
- Codex CLI: `~/.codex/AGENTS.md` (and any project-level `AGENTS.md`)
- Gemini CLI: `~/.gemini/GEMINI.md`

Check for:
- Valid frontmatter (`alwaysApply`, `globs`/`paths`, `description`)
- Corrupt or placeholder content
- Redundancy with skills

**Journal analysis** — Read all files in `<thoughts-dir>/` (placeholder resolved by `journal-config.local.mdc`; default `~/code/thoughts/`):
- All daily files, `ideas.md`, `open-questions.md`, `decisions.md`, `til.md`, `parking-lot.md`
- `projects/` and `weekly/` directories
- Identify: most-used sections, empty/unused sections, duplication patterns

**Transcript analysis** — Sample 8-10 recent agent transcripts from the IDE's transcripts folder (location varies by IDE):
- Which skills are explicitly triggered (`manually_attached_skills` or equivalent)
- Common task patterns without matching skills
- Where the agent struggled or the user repeated themselves
- Which tools/technologies appear most

**Config review** — Check, for each installed IDE:
- MCP server configuration (`~/.cursor/mcp.json`, `~/.claude/.mcp.json`, `~/.codex/config.toml`, `~/.gemini/settings.json`)
- Project-level `AGENTS.md` files in workspace repos
- Any IDE-specific CLI config files

### 3. Cross-reference usage vs inventory

Compare what exists against what's actually used:

- **Skills triggered in transcripts** vs **skills that exist** → find unused skills
- **Recurring task patterns** vs **available skills** → find gaps (potential new skills)
- **Journal sections with content** vs **sections that are empty** → find structural issues
- **Rules loaded** vs **rules that affect behavior** → find dead rules
- **IDE coverage gaps**: skills/rules present in one IDE but missing from another the user actively uses

### 4. Assess quality

For each skill, evaluate:
- Is the description specific enough for auto-discovery? Does it include natural trigger phrases?
- Is the SKILL.md under 500 lines?
- Are there supporting files that could be consolidated or are unused?
- Does the skill overlap significantly with another?

For rules:
- Is the frontmatter valid?
- Is the content actually rule guidance (not corrupted/placeholder)?
- Is `alwaysApply` set correctly? (Should conditional rules be always-on, or vice versa?)
- For IDEs with a single global rules file (Codex, Gemini): are managed sections still bracketed by their begin/end markers, or has the user inadvertently broken the markers?

For journal:
- Are persistent files (`ideas.md`, `open-questions.md`, `parking-lot.md`) being populated, or does everything stay in session blocks?
- Is there a TIL duplication issue (daily `## TIL` vs `til.md`)?
- Are project files being created for active projects?

### 5. Generate recommendations

Categorize findings into:

**Immediate fixes** — Corrupt files, broken rules, duplication that's actively harmful.

**Skill modifications** — Description improvements, workflow tweaks, missing steps in existing skills.

**New skills** — Recurring patterns from transcripts that would benefit from codification. For each, provide a name, one-line description, and the pattern it addresses.

**Structural changes** — Journal template changes, rule additions, config adjustments, IDE-coverage gaps to close.

**Deprecation candidates** — Skills that are never used and don't serve a clear future need.

### 6. Present findings

Structure the report as:

```
## Agent Setup Review — YYYY-MM-DD

### IDEs detected
- Cursor (~/.cursor/) — N skills, M rules
- Claude Code (~/.claude/) — N skills, M rules + CLAUDE.md managed section

### What's Working Well
- Skills/rules that are actively used and delivering value

### Issues Found
- Bugs, corruption, misconfiguration

### Unused / Underutilized
- Skills never triggered, journal sections always empty

### IDE Coverage Gaps
- Skill/rule X is in Cursor but missing from Claude Code despite both being active

### Recommended Changes
1. [Priority] Category: description of change and rationale
2. ...

### New Skill Candidates
| Name | Description | Pattern it addresses |
|------|-------------|---------------------|
| ... | ... | ... |
```

Present findings conversationally and ask the user which items to implement.
