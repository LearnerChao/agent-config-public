---
name: project-context-restore
description: >-
  Restore context for a specific project by reviewing recent journal entries,
  decisions, and open items. Use when the user says "catch me up on [project]",
  "where did I leave off", "restore context", "what's the status of [project]",
  "what's happening with [project]", "remind me about [project]",
  "context for [project]", "pick up where I left off",
  or is returning to a project after time away.
---

# Project Context Restore

Rebuild working context for a project by mining the journal.

## Workflow

### 1. Identify the project

Determine the target project from the user's message. If ambiguous, list projects that appear in recent daily files and ask the user to pick one.

### 2. Search the journal

Search these files in `<thoughts-dir>/` (placeholder resolved by `journal-config.local.mdc`; default `~/code/thoughts/`) for mentions of the project name:

- `daily/*.md` — focus on the **last 10 daily files** to keep scope manageable
- `projects/{project-name}.md` — if it exists, read it in full
- `decisions.md` — find decisions tagged with this project
- `open-questions.md` — find questions tagged with this project
- `ideas.md` — find ideas tagged with this project

Use grep or similar search across files. The project name may appear in **Project** fields, bracketed tags like `[project-name]`, or in prose.

### 3. Build the context brief

Synthesize findings into:

```
## Context Restore — project-name

### Last Session
**Date**: YYYY-MM-DD
**Summary**: What was done in the most recent session.

### Open Items
- [ ] Unfinished task from MM-DD
- [ ] Another task from MM-DD

### Recent Decisions
- DEC-YYYY-MM-DD-N: Decision summary

### Open Questions
- Question text (asked MM-DD)

### Active Ideas
- Idea text (captured MM-DD)

### Timeline (last 2 weeks)
- MM-DD: Brief summary of that day's session(s)
- MM-DD: Brief summary
```

### 4. Optionally verify against the codebase

If the project path is known or inferrable (e.g., `~/code/project-name/`), offer to check the actual state:
- Recent git log (last 5 commits)
- Any uncommitted changes
- Branch status

Present discrepancies between notes and actual repo state if found.

### 5. Present to user

Display the context brief conversationally. Highlight the most actionable next step.
