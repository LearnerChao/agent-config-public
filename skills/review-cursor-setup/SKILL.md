---
name: review-cursor-setup
description: >-
  Audit the Cursor setup — skills, rules, journal, agent transcripts, and MCP
  config — to find what's working, what's unused, and what's missing. Suggests
  additions, modifications, and cleanup. Use when the user says "review my setup",
  "audit my skills", "review cursor config", "what skills should I add",
  "how is my setup working", or "optimize my cursor setup".
---

# Review Cursor Setup

Perform a comprehensive audit of the user's Cursor configuration by analyzing what exists, how it's actually being used, and where the gaps are.

## Workflow

### 1. Gather inventory (parallel)

Launch parallel explore agents to collect:

**Skills inventory** — Read every `SKILL.md` in:
- `~/.cursor/skills/` (personal)
- `.cursor/skills/` in any workspace repos

For each: name, description, line count, supporting files.

**Rules inventory** — Read every `.mdc` in `~/.cursor/rules/`. Check for:
- Valid frontmatter (`alwaysApply`, `globs`, `description`)
- Corrupt or placeholder content
- Redundancy with skills

**Journal analysis** — Read all files in `<thoughts-dir>/` (placeholder resolved by `journal-config.local.mdc`; default `~/code/thoughts/`):
- All daily files, `ideas.md`, `open-questions.md`, `decisions.md`, `til.md`, `parking-lot.md`
- `projects/` and `weekly/` directories
- Identify: most-used sections, empty/unused sections, duplication patterns

**Transcript analysis** — Sample 8-10 recent agent transcripts from the transcripts folder:
- Which skills are explicitly triggered (`manually_attached_skills`)
- Common task patterns without matching skills
- Where the agent struggled or the user repeated themselves
- Which tools/technologies appear most

**Config review** — Check:
- MCP server configuration (`~/code/cursor-config/mcp.json` or `~/.cursor/mcp.json`)
- `AGENTS.md` files in workspace repos
- CLI config (`~/.cursor/cli-config.json`)

### 2. Cross-reference usage vs inventory

Compare what exists against what's actually used:

- **Skills triggered in transcripts** vs **skills that exist** → find unused skills
- **Recurring task patterns** vs **available skills** → find gaps (potential new skills)
- **Journal sections with content** vs **sections that are empty** → find structural issues
- **Rules loaded** vs **rules that affect behavior** → find dead rules

### 3. Assess quality

For each skill, evaluate:
- Is the description specific enough for auto-discovery? Does it include natural trigger phrases?
- Is the SKILL.md under 500 lines?
- Are there supporting files that could be consolidated or are unused?
- Does the skill overlap significantly with another?

For rules:
- Is the frontmatter valid?
- Is the content actually rule guidance (not corrupted/placeholder)?
- Is `alwaysApply` set correctly? (Should conditional rules be always-on, or vice versa?)

For journal:
- Are persistent files (`ideas.md`, `open-questions.md`, `parking-lot.md`) being populated, or does everything stay in session blocks?
- Is there a TIL duplication issue (daily `## TIL` vs `til.md`)?
- Are project files being created for active projects?

### 4. Generate recommendations

Categorize findings into:

**Immediate fixes** — Corrupt files, broken rules, duplication that's actively harmful.

**Skill modifications** — Description improvements, workflow tweaks, missing steps in existing skills.

**New skills** — Recurring patterns from transcripts that would benefit from codification. For each, provide a name, one-line description, and the pattern it addresses.

**Structural changes** — Journal template changes, rule additions, config adjustments.

**Deprecation candidates** — Skills that are never used and don't serve a clear future need.

### 5. Present findings

Structure the report as:

```
## Cursor Setup Review — YYYY-MM-DD

### What's Working Well
- Skills/rules that are actively used and delivering value

### Issues Found
- Bugs, corruption, misconfiguration

### Unused / Underutilized
- Skills never triggered, journal sections always empty

### Recommended Changes
1. [Priority] Category: description of change and rationale
2. ...

### New Skill Candidates
| Name | Description | Pattern it addresses |
|------|-------------|---------------------|
| ... | ... | ... |
```

Present findings conversationally and ask the user which items to implement.
